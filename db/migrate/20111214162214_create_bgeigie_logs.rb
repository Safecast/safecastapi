class CreateBgeigieLogs < ActiveRecord::Migration
  def change
    create_table :bgeigie_logs do |t|
      t.string :device_tag
      t.string :device_serial_id
      t.datetime :captured_at
      t.integer :cpm
      t.integer :counts_per_five_seconds
      t.integer :total_counts
      t.string :cpm_validity
      t.float :latitude_nmea
      t.string :north_south_indicator
      t.float :longitude_nmea
      t.string :east_west_indicator
      t.float :altitude
      t.string :gps_fix_indicator
      t.float :horizontal_dilution_of_precision
      t.string :gps_fix_quality_indicator

      t.timestamps
    end
  end
end
