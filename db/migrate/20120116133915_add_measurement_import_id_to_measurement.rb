class AddMeasurementImportIdToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :measurement_import_id, :integer
    add_index :measurements, :measurement_import_id
  end
end
