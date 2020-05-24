#!/usr/bin/env python3

# Currently for deploying when you also want to create a new
# environment, not for redeploying to an existing environment.

import sys
if sys.version_info.major < 3 or sys.version_info.minor < 7:
    print("Error: This script requires at least Python 3.7.", file=sys.stderr)
    exit(1)

import argparse
import boto3
import re
import time

def verbose_sleep(secs):
    end_time = time.strftime('%Y-%m-%dT%H:%M:%S%z', time.localtime(time.time() + secs))
    print("Sleeping for " + str(secs) + "seconds until " + end_time, file=sys.stderr)
    time.sleep(secs)

def get_previously_deployed_version(current_envs, env_name):
    env_dict = [env  for env in current_envs if env['EnvironmentName'] == env_name][0]
    return env_dict['VersionLabel']
    
def identify_current_envs(current_envs):
    current_env_names = [env['EnvironmentName'] for env in current_envs]
    env_patterns = {
        'dev_web': re.compile(r'safecastapi-dev-(?P<num>\d{3})'),
        'dev_wrk': re.compile(r'safecastapi-dev-wrk-(?P<num>\d{3})'),
        'prd_web': re.compile(r'safecastapi-prd-(?P<num>\d{3})'),
        'prd_wrk': re.compile(r'safecastapi-prd-wrk-(?P<num>\d{3})'),
    }
    env_metadata = {}
    for pattern_name, pattern in env_patterns.items():
        matching_envs = [pattern.fullmatch(name) for name in current_env_names if pattern.fullmatch(name)]
        if len(matching_envs) == 1:
            env_metadata[pattern_name] = {
                'name': matching_envs[0].string,
                'num': int(matching_envs[0].group('num')),
            }
        elif len(matching_envs) > 1:
            # TODO it would be nice to match on endpoint URL to
            # automatically detect the correct current environment for
            # the web tier
            # env_list = list(enumerate([match.string for match in matching_envs]))
            print("More than one "
                  + pattern_name
                  + """ environment was found, which one is the current environment?\n
                  TODO implement this once it becomes a problem. Exiting.
                  """, file=sys.stderr)
            exit(1)
        else:
            print("No matching environment for "
                  + pattern_name
                  + "was found, not able to handle this scenario, exiting. TODO",
                  file=sys.stderr)
            exit(1)
            
    return env_metadata

def main():
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('app', help="The target application to deploy to. Only 'api' works at this point.")
    arg_parser.add_argument('env', help="The target environment to deploy to. Either 'dev' or 'prd'.")
    arg_parser.add_argument('version', help="The new version to deploy.")
    arg_parser.add_argument('arn', help="The ARN the new deployment should use.")
    args = arg_parser.parse_args()
    target_app = args.app
    target_env = args.env
    target_version = args.version
    target_arn = args.arn

    target_web_tier = target_env + '_web'
    target_wrk_tier = target_env + '_wrk'
    target_web_template = target_env
    target_wrk_template = target_env + '-wrk'

    ebclient = boto3.client('elasticbeanstalk')

    current_envs = ebclient.describe_environments(ApplicationName=target_app, IncludeDeleted=False)['Environments']
    current_env_metadata = identify_current_envs(current_envs)

    # TODO need to be able to loop back to 0
    new_web_env_name = 'safecastapi-{target_env}-{num:03}' \
        .format(target_env=target_env, num=current_env_metadata[target_web_tier]['num'] + 1)
    new_wrk_env_name = 'safecastapi-{target_env}-wrk-{num:03}' \
        .format(target_env=target_env, num=current_env_metadata[target_wrk_tier]['num'] + 1)

    # Switch over to new worker environment first

    # First, turn off the current worker to avoid any concurrency issues
    print("Setting the worker tier to scale to 0.", file=sys.stderr)
    ebclient.update_environment(ApplicationName=target_app, EnvironmentName=current_env_metadata[target_wrk_tier]['name'],
                                OptionSettings=[
                                    {
                                        'ResourceName': 'AWSEBAutoScalingGroup',
                                        'Namespace': 'aws:autoscaling:asg',
                                        'OptionName': 'MaxSize',
                                        'Value': '0',
                                    },
                                    {
                                        'ResourceName': 'AWSEBAutoScalingGroup',
                                        'Namespace': 'aws:autoscaling:asg',
                                        'OptionName': 'MinSize',
                                        'Value': '0'
                                    },
                                ])
    verbose_sleep(120)
    print("Creating the new worker environment.", file=sys.stderr)
    ebclient.create_environment(
        ApplicationName=target_app,
        EnvironmentName=new_wrk_env_name,
        PlatformArn=target_arn,
        TemplateName=target_wrk_template,
        VersionLabel=target_version,
    )
    verbose_sleep(360)
    print("Terminating the old worker environment.", file=sys.stderr)
    ebclient.terminate_environment(ApplicationName=target_app, EnvironmentName=current_env_metadata[target_wrk_tier]['name'])

    # Next, the Web tier
    print("Creating the new Web environment.", file=sys.stderr)
    ebclient.create_environment(
        ApplicationName=target_app,
        EnvironmentName=new_web_env_name,
        PlatformArn=target_arn,
        TemplateName=target_web_template,
        VersionLabel=target_version,
    )
    verbose_sleep(360)
    print("Swapping web environment CNAMEs.", file=sys.stderr)
    ebclient.swap_environment_cnames(
        SourceEnvironmentName=current_env_metadata[target_web_tier]['name'],
        DestinationEnvironmentName=new_web_env_name,
    )
    verbose_sleep(120)
    print("Terminating the old web environment.", file=sys.stderr)
    ebclient.terminate_environment(ApplicationName=target_app, EnvironmentName=current_env_metadata[target_web_tier]['name'])

    print("Changeover completed.", file=sys.stderr)
    print("Old build on worker was: "
          + get_previously_deployed_version(current_envs, current_env_metadata[target_wrk_tier]['name']),
          file=sys.stderr)
    print("Old build on web was: "
          + get_previously_deployed_version(current_envs, current_env_metadata[target_web_tier]['name']),
          file=sys.stderr)

    # TODO new configuration template is not saved, this seems to only be possible from eb cli, not boto

if __name__ == '__main__':
    main()
