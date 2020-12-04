# frozen_string_literal: true

class CreateDeviceStoryComments < ActiveRecord::Migration[5.2]
  def change
    create_table :device_story_comments do |t|
      t.references :device_story, foreign_key: true
      t.references :user, foreign_key: true
      t.text :text

      t.timestamps
    end
  end
end
