# frozen_string_literal: true

namespace :elasticbeanstalk do
  desc 'Creates a new web & worker environment pair for testing'
  task :create do
    require 'aws-sdk-elasticbeanstalk'

    environment_config = ENV['AWS_EB_CFG'] || 'dev'
    environment_prefix = 'safecastapi-' + environment_config

    raise 'AWS_EB_DATABASE_HOST must be specified' unless ENV['AWS_EB_DATABASE_HOST']
    raise 'AWS_EB_DATABASE_PASSWORD must be specified' unless ENV['AWS_EB_DATABASE_PASSWORD']
    raise 'AWS_EFS_VOLUME must be specified' unless ENV['AWS_EFS_VOLUME']

    envvars = {
      DATABASE_HOST: ENV['AWS_EB_DATABASE_HOST'],
      DATABASE_PASSWORD: ENV['AWS_EB_DATABASE_PASSWORD'],
      AWS_EFS_VOLUME: ENV['AWS_EFS_VOLUME'],
      S3_BUCKET: ENV['S3_BUCKET'],
      S3_BUCKET_REGION: ENV['S3_BUCKET_REGION'],
      RAILS_SKIP_MIGRATIONS: true
    }

    # Determine latest platform version
    minor_version = RUBY_VERSION.split('.')[0..1].join('.')
    elasticbeanstalk = Aws::ElasticBeanstalk::Client.new
    platform_arn = elasticbeanstalk.list_platform_versions(filters: [
      {
        type: 'PlatformName',
        operator: 'begins_with',
        values: ["Puma with Ruby #{minor_version}"]
      },
      {
        type: 'PlatformVersion',
        operator: '=',
        values: ['latest']
      }
    ]).platform_summary_list.first.platform_arn

    # Determine next environment serial number
    environments = elasticbeanstalk.describe_environments(application_name: 'api').environments
    environment_names = environments.map(&:environment_name)
    selected_environments = environment_names.select { |n| n =~ /^#{environment_prefix}-/ }
    previous_environment_number = selected_environments.sort.last.split('-').last.to_i
    environment_number = format('%03d', previous_environment_number + 1)

    base_command = [
      'eb', 'create',
      '--platform', platform_arn,
      '--instance_type', 't2.small',
      '--instance_profile', environment_prefix,
      '--envvars', envvars.map { |k, v| [k, v].join('=') }.join(',')
    ]

    worker_command = base_command + [
      '--tier', 'worker',
      '--cfg', environment_config + '-wrk',
      [environment_prefix, 'wrk', environment_number].join('-')
    ]

    web_command = base_command + [
      '--cfg', environment_config,
      [environment_prefix, environment_number].join('-')
    ]

    sh(*worker_command)
    sh(*web_command)
  end
end
