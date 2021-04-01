class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.integer :user_id
      t.integer :value

      t.timestamps
    end
    
    add_index :measurements, :user_id
  end
end
