# frozen_string_literal: true

namespace :device_story do
  desc 'Update device metadata from ttserve'
  task update_metadata: :environment do
    Tasks::DeviceStory::UpdateMetadata.call
  end
end
