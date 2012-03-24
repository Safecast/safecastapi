class DriveImport < MeasurementImport
  has_many :drive_logs
  def self.update_locations
    self.find_each do |drive_import|
      puts "\nDrive ID: #{drive_import.id}"
      drive_import.drive_logs.find_each do |drive_log|
        drive_log.update_location rescue nil
        print '.'
      end
    end
  end

  def self.update_md5sums
    self.find_each do |drive_import|
      transaction do
        drive_import.drive_logs.find_each do |drive_log|
          drive_log.update_md5sum
        end
      end
    end
  end

  def user_id
    1
  end

  def import_measurements
    self.connection.execute("insert into measurements
                             (user_id, value, unit, created_at, updated_at, captured_at,
                             measurement_import_id, md5sum, location)
                             select #{self.user_id},reading_value,'cpm', created_at, updated_at, reading_date,
                             #{self.id}, md5sum, location
                             from drive_logs WHERE
                             drive_log_id = #{self.id}
                             and md5sum not in (select md5sum from measurements)")
  end
  
  def add_measurements_to_map
    self.connection.execute(%Q[insert into maps_measurements (map_id, measurement_id)
                                select #{@map.id}, id from measurements
                                where measurement_import_id = #{self.id}])
  end

end