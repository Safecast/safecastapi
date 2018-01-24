class AddSpatialIndexOnMeasurements < ActiveRecord::Migration
  def up
    remove_index :measurements, column: :location
    add_index :measurements, :location, using: :gist
  end

  def down
    remove_index :measurements, column: :location
    add_index :measurements, :location, using: :gist
  end
end
