class ChangeDriveLogFloatLimitTo24 < ActiveRecord::Migration
  def up
    change_column :drive_logs, :latitude, :float, :length => 8
    change_column :drive_logs, :longitude, :float, :length => 8
  end

  def down
    change_column :drive_logs, :latitude, :float, :limit => 8
    change_column :drive_logs, :longitude, :float, :limit => 8
  end
end
