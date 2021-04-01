class CreateDriveLogs < ActiveRecord::Migration
  def change
    create_table :drive_logs do |t|
      t.integer :measurement_import_id
      t.datetime :reading_date
      t.float :reading_value
      t.integer :unit_id
      t.float :alt_reading_value
      t.integer :alt_unit_id
      t.integer :rolling_count
      t.integer :total_count
      t.float :latitude, :limit => 8
      t.float :longitude, :limit => 8
      t.integer :gps_quality_indicator
      t.integer :satellite_num
      t.float :gps_precision
      t.float :gps_altitude
      t.string :gps_device_name
      t.string :measurement_type
      t.string :zoom_7_grid

      t.timestamps
    end
    add_index :drive_logs, :measurement_import_id
  end
end
