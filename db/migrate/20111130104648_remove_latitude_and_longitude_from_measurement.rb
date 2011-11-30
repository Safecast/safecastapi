class RemoveLatitudeAndLongitudeFromMeasurement < ActiveRecord::Migration
  def up
    remove_column :measurements, :latitude
    remove_column :measurements, :longitude
  end

  def down
    add_column :measurements, :longitude, :float
    add_column :measurements, :latitude, :float
  end
end
