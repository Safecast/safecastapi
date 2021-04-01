class AddLocationToDriveLog < ActiveRecord::Migration
  def change
    add_column :drive_logs, :location, :st_point, geographic: true
  end
end
