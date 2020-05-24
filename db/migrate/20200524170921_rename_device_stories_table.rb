class RenameDeviceStoriesTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :device_story_devices, :device_stories
  end
end
