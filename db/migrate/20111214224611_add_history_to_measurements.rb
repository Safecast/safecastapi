class AddHistoryToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :original_id, :integer
    add_column :measurements, :expired_at, :timestamp
    add_column :measurements, :replaced_by, :integer
    add_column :measurements, :updated_by, :integer
    
    add_index :measurements, :original_id
  end
end
