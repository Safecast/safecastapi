class AddDeviceToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :device_id, :integer
  end
end
