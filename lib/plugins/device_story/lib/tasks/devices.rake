# frozen_string_literal: true

namespace :device_metadata do
  desc 'Update device metadata from ttserve'
  task update: :environment do
    DeviceStory::Device.all

    DeviceStory::Tasks::UpdateDeviceMetadata.call
  end
end
