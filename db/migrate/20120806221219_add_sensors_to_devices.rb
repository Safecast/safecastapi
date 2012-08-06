class AddSensorsToDevices < ActiveRecord::Migration
  def change
    create_table :devices_sensors, :id => false do |t|
      t.references :device, :sensor
    end
  end
end
