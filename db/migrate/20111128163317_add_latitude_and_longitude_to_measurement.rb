class AddLatitudeAndLongitudeToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :latitude, :float
    add_column :measurements, :longitude, :float
  end
end
