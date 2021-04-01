class AddDeviceToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :device_id, :integer
    
    add_index :measurements, :device_id
  end
end
