class RemoveDeviceStringsFromMaps < ActiveRecord::Migration
  def up
    remove_column :maps, :device_mfg
    remove_column :maps, :device_model
    remove_column :maps, :device_sensor
  end

  def down
    add_column :maps, :device_sensor, :string
    add_column :maps, :device_model, :string
    add_column :maps, :device_mfg, :string
  end
end
