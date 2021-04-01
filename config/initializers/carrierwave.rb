# frozen_string_literal: true

CarrierWave.configure do |config| # rubocop:disable Metrics/BlockLength
  # noinspection RubyResolve
  if ENV.key? 'S3_BUCKET'
    config.fog_provider = 'fog/aws'
    config.fog_directory = ENV['S3_BUCKET']
    config.fog_public = true

    bucket_region = ENV['S3_BUCKET_REGION'] || case Rails.env
                                               when 'development'
                                                 'ap-northeast-1'
                                               when 'staging'
                                                 'us-east-1'
                                               else
                                                 'us-west-2'
                                               end

    config.fog_credentials = if ENV.key? 'AWS_ACCESS_KEY_ID'
                               { provider: 'AWS',
                                 aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                 aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                 region: bucket_region }
                             else
                               { provider: 'AWS',
                                 use_iam_profile: true,
                                 region: bucket_region }
                             end
    config.storage = :fog
  else
    config.storage = :file
    config.enable_processing = false
  end
end
