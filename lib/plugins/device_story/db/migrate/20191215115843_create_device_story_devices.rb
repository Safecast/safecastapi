# frozen_string_literal: true

class CreateDeviceStoryDevices < ActiveRecord::Migration
  def change
    create_table :device_story_devices do |t|
      t.jsonb :metadata, null: false, default: '{}'
      t.text :comment
      t.references :user
    end
  end
end
