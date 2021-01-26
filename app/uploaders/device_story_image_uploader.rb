# frozen_string_literal: true

class DeviceStoryImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
  process convert: 'png'
  process tags: ['post_picture']

  version :standard do
    process resize_to_fill: [100, 150, :north]
  end

  version :thumbnail do
    resize_to_fit(50, 50)
  end

  def public_id
    'device_story_images/' + Cloudinary::Utils.random_public_id
  end
end
