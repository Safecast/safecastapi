class RemoveSensorFromDevice < ActiveRecord::Migration
  def up
    remove_column :devices, :sensor
  end

  def down
    add_column :devices, :sensor, :string
  end
end
