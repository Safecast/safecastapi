class RenameMeasurementImportIdToDriveImportIdOnDriveLog < ActiveRecord::Migration
  def change
    rename_column :drive_logs, :measurement_import_id, :drive_import_id
  end
end
