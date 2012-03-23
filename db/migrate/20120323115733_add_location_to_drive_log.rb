class AddLocationToDriveLog < ActiveRecord::Migration
  def change
    add_column :drive_logs, :location, :point, :geographic => true
  end
end
