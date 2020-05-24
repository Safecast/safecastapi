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
import yaml

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
    arg_parser.add_argument('env', help="The target environment to deploy to. Either 'dev' or 'prd'.")
    arg_parser.add_argument('version', help="The new version to deploy.")
    args = arg_parser.parse_args()
    target_env = args.env
    target_version = args.version

    ebclient = boto3.client('elasticbeanstalk')

    current_envs = ebclient.describe_environments(ApplicationName='api', IncludeDeleted=False)['Environments']
    current_env_metadata = identify_current_envs(current_envs)

    print(current_env_metadata)

if __name__ == '__main__':
    main()
