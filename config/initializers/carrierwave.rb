CarrierWave.configure do |config|
  if Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  end

  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: Configurable.aws_access_key_id,
    aws_secret_access_key: Configurable.aws_secret_access_key,
    region: 'us-east-1'
  }
  config.fog_directory = Configurable.s3_bucket
  config.fog_public = true
  config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
end
