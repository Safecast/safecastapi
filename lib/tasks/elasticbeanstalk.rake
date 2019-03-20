# frozen_string_literal: true

namespace :elasticbeanstalk do
  desc 'Gets the arn for the platform ARN with the current ruby version'
  task :platform_arn do
    require 'aws-sdk-elasticbeanstalk'
    elasticbeanstalk = Aws::ElasticBeanstalk::Client.new

    minor_version = RUBY_VERSION.split('.')[0..1].join('.')
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
    puts platform_arn
  end

  desc 'Creates a new web & worker environment pair for testing'
  task :create do
    require 'aws-sdk-elasticbeanstalk'
    elasticbeanstalk = Aws::ElasticBeanstalk::Client.new

    environment_config = ENV['AWS_EB_CFG'] || 'dev'
    environment_prefix = 'safecastapi-' + environment_config

    # Determine next environment serial number
    environments = elasticbeanstalk.describe_environments(application_name: 'api').environments
    environment_names = environments.map(&:environment_name)
    selected_environments = environment_names.select { |n| n =~ /^#{environment_prefix}-/ }
    previous_environment_number = if selected_environments.empty?
                                    0
                                  else
                                    selected_environments.sort.last.split('-').last.to_i
                                  end
    environment_number = format('%03d', previous_environment_number + 0)

    base_command = %w(eb create)

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
