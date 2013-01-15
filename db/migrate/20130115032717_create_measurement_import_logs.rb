class CreateMeasurementImportLogs < ActiveRecord::Migration
  def change
    create_table :measurement_import_logs do |t|
      t.integer :measurement_import_id
      t.text :description

      t.timestamps
    end
  end
end
