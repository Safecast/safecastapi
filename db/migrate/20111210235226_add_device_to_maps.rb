class AddDeviceToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :device_id, :integer
    
    add_index :maps, :device_id
  end
end
