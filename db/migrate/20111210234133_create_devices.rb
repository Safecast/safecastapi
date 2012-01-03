class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :mfg
      t.string :model
      t.string :sensor

      t.timestamps
    end
  end
end
