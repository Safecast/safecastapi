class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :manufacturer
      t.string :model
      t.string :serial_number
      t.string :type

      t.timestamps
    end

    add_index :sensors, :model
    add_index :sensors, :serial_number
    add_index :sensors, :type
    
    create_table :devices_sensors, :id => false do |t|
      t.references :device, :sensor
    end
  end
end
