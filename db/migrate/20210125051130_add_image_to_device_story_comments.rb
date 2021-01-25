# frozen_string_literal: true

class AddImageToDeviceStoryComments < ActiveRecord::Migration[5.2]
  def change
    add_column :device_story_comments, :image, :string
  end
end
