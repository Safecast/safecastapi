class AddSensorToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :sensor_id, :integer
    add_index :measurements, :sensor_id
  end
end
