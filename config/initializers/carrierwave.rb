CarrierWave.configure do |config|
  case Rails.env
  when 'test'
    config.storage = :file
    config.enable_processing = false
  when 'development'
    if ENV['S3_BUCKET']
      config.fog_provider = 'fog/aws'
      config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: 'ap-northeast-1'
      }
      config.fog_directory = ENV['S3_BUCKET']
      config.fog_public = true
      config.storage = :fog
    else
      config.storage = :file
    end
  when 'production', 'staging'
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: 'us-east-1'
    }
    config.fog_directory = ENV['S3_BUCKET']
    config.fog_public = true
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    config.storage = :fog
  else
    raise "Unrecognized Rails environment #{Rails.env}"
  end
end
