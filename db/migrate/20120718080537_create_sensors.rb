class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :manufacturer
      t.string :model
      t.string :serial_number
      t.string :measurement_category
      t.string :measurement_type

      t.timestamps
    end

    add_index :sensors, :model
    add_index :sensors, :serial_number
    add_index :sensors, :measurement_category
    add_index :sensors, :measurement_type
  end
end
