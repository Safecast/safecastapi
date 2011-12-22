class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :description
      t.string :device_mfg
      t.string :device_model
      t.string :device_sensor

      t.timestamps
    end
  end
end
