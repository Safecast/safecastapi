class AddDeviceToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :device_id, :integer
  end
end
