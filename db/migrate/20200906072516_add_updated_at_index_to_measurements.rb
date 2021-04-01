# frozen_string_literal: true

class AddUpdatedAtIndexToMeasurements < ActiveRecord::Migration[5.2]
  def change
    add_index :measurements, :updated_at
  end
end
