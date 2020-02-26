# frozen_string_literal: true

class CreateDeviceStoryDevices < ActiveRecord::Migration
  def change
    create_table :device_story_devices do |t|
      t.references :user

      t.string :device_urn, null: false
      t.jsonb :metadata
      t.text :comment

      t.timestamps null: false

      t.index :device_urn
    end
  end
end
