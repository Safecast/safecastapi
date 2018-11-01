class AddLocationToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :location, :st_point, geographic: true
  end
end
