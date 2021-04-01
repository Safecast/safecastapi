# frozen_string_literal: true

class AddMoreColumnsToDeviceStoryDevices < ActiveRecord::Migration
  def change
    add_column :device_story_devices, :device_id, :integer, limit: 8
    add_column :device_story_devices, :last_location, :st_point, geographic: true
    add_column :device_story_devices, :last_values, :string
  end
end
