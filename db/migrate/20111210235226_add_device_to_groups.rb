class AddDeviceToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :device_id, :integer
    
    add_index :groups, :device_id
  end
end
