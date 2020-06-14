# frozen_string_literal: true

class ExtractValuesFromMedadata < ActiveRecord::Migration[5.2]
  def change
    add_column :device_stories, :last_seen, :datetime
    add_column :device_stories, :last_location_name, :string
    add_column :device_stories, :custodian_name, :string

    Tasks::DeviceStories::UpdateMetadata.call
  end
end
