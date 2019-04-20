# frozen_string_literal: true

require 'elasticbeanstalk_helper'

elasticbeanstalk_app = 'api'
elasticbeanstalk_prefix = 'safecastapi'

namespace :elasticbeanstalk do
  desc 'Gets the arn for the platform ARN with the current ruby version'
  task :platform_arn do
    puts ElasticBeanstalkHelper.platform_arn
  end

  desc 'Creates a new web & worker environment pair for testing'
  task :create do
    helper = ElasticBeanstalkHelper.new(elasticbeanstalk_app, elasticbeanstalk_prefix)

    p(*helper.create_command('wrk'))
    p(*helper.create_command)
  end
end

%i(dev prd).each do |environment_config|
  desc "SSH to #{environment_config}"
  task "ssh_#{environment_config}" do
    helper = ElasticBeanstalkHelper.new(elasticbeanstalk_app, elasticbeanstalk_prefix, environment_config)
    exec(*helper.ssh_command)
  end

  desc "SSH to #{environment_config}-wrk"
  task "ssh_#{environment_config}_wrk" do
    helper = ElasticBeanstalkHelper.new(elasticbeanstalk_app, elasticbeanstalk_prefix, environment_config)
    exec(*helper.ssh_command('wrk'))
  end

  desc "Deploy to #{environment_config}"
  task "deploy_#{environment_config}" do
    helper = ElasticBeanstalkHelper.new(elasticbeanstalk_app, elasticbeanstalk_prefix, environment_config)
    exec(*helper.deploy_command)
  end

  desc "Deploy to #{environment_config}-wrk"
  task "deploy_#{environment_config}_wrk" do
    helper = ElasticBeanstalkHelper.new(elasticbeanstalk_app, elasticbeanstalk_prefix, environment_config)
    exec(*helper.deploy_command('wrk'))
  end
end
