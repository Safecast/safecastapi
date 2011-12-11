class RemoveDeviceStringsFromGroups < ActiveRecord::Migration
  def up
    remove_column :groups, :device_mfg
    remove_column :groups, :device_model
    remove_column :groups, :device_sensor
  end

  def down
    add_column :groups, :device_sensor, :string
    add_column :groups, :device_model, :string
    add_column :groups, :device_mfg, :string
  end
end
