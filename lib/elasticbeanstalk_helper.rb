# frozen_string_literal: true

require 'aws-sdk-elasticbeanstalk'

class ElasticBeanstalkHelper
  attr_reader :elasticbeanstalk, :application_name, :environment_prefix, :environment_config

  def initialize(application_name, environment_prefix, environment_config = nil)
    if environment_config.nil?
      environment_config = (ENV['AWS_EB_CFG'] || 'dev')
    end

    @application_name = application_name
    @environment_prefix = environment_prefix
    @environment_config = environment_config
    @elasticbeanstalk = Aws::ElasticBeanstalk::Client.new
  end

  def platform_arn
    minor_ruby_version = RUBY_VERSION.split('.')[0..1].join('.')
    elasticbeanstalk.list_platform_versions(filters: [
      { type: 'PlatformName',
        operator: 'begins_with',
        values: ["Puma with Ruby #{minor_ruby_version}"] },
      { type: 'PlatformVersion',
        operator: '=',
        values: ['latest'] }
    ]).platform_summary_list.first.platform_arn
  end

  def selected_environments
    environments = elasticbeanstalk.describe_environments(application_name: application_name).environments
    environment_names = environments.map(&:environment_name)
    environment_names.grep { |n| n =~ /^#{environment_prefix}-#{environment_config}-/ }
  end

  def current_environment_number
    if selected_environments.empty?
      0
    else
      selected_environments.max.split('-').last.to_i
    end
  end

  def next_environment_number
    current_environment_number + 1
  end

  def environment_name(number, tier = nil)
    formatted_number = format('%03d', number)

    if tier == 'wrk'
      [environment_prefix, environment_config, 'wrk', formatted_number].join('-')
    else
      [environment_prefix, environment_config, formatted_number].join('-')
    end
  end

  def eb_config(tier = nil)
    if tier == 'wrk'
      "#{environment_config}-wrk"
    else
      environment_config
    end
  end

  def create_command(tier = nil)
    %w(eb create) + [
      '--cfg', eb_config(tier),
      environment_name(next_environment_number, tier)
    ]
  end

  def ssh_command(tier = nil)
    %w(eb ssh) + [environment_name(current_environment_number, tier)]
  end

  def deploy_command(tier = nil)
    %w(eb deploy) + [environment_name(current_environment_number, tier)]
  end

  def swap_command(tier = nil)
    current = current_environment_number
    %W(eb swap #{environment_name(current, tier)} -n #{environment_name(current - 1, tier)})
  end
end
