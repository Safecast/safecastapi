class AddUniqueMd5sumIndexToDriveLog < ActiveRecord::Migration
  def change
    add_index :drive_logs, :md5sum, :unique => true
  end
end
