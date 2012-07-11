class AddSerialNumberToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :serial_number, :string
  end
end
