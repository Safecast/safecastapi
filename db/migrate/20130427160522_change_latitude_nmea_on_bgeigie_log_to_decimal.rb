class ChangeLatitudeNmeaOnBgeigieLogToDecimal < ActiveRecord::Migration
  def up
    change_column :bgeigie_logs, :latitude_nmea, :numeric, :precision => 5, :scale => 4
    change_column :bgeigie_logs, :longitude_nmea, :numeric, :precision => 5, :scale => 4
  end

  def down
    change_column :bgeigie_logs, :latitude_nmea, :float
    change_column :bgeigie_logs, :longitude_nmea, :float
  end
end
