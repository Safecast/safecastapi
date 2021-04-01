class AddMd5sumToDriveLog < ActiveRecord::Migration
  def change
    add_column :drive_logs, :md5sum, :string
  end
end
