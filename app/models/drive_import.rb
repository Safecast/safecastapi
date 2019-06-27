# frozen_string_literal: true

class DriveImport < MeasurementImport
  has_many :drive_logs

  def self.process
    update_locations
    update_md5sums
    find_each(&:process)
  end

  def self.update_locations # rubocop:disable Metrics/MethodLength
    find_each do |drive_import|
      puts "\nDrive ID: #{drive_import.id}"
      drive_import.drive_logs.find_each do |drive_log|
        begin
          drive_log.update_location
        rescue # rubocop:disable Style/RescueStandardError
          nil
        end
        print '.'
      end
    end
  end

  def self.update_md5sums
    find_each do |drive_import|
      transaction do
        drive_import.drive_logs.find_each(&:update_md5sum)
      end
    end
  end

  def name
    read_attribute(:name).presence || "Drive ##{id}"
  end

  def process
    update_attribute(:status, 'processing')
    import_measurements
    create_map
    add_measurements_to_map
    update_attribute(:status, 'done')
  end

  def create_map
    @map = map || user.maps.create!(name: name.to_s,
                                    description: description.to_s)
    update_attribute(:map, @map)
  end

  def user
    User.find user_id
  end

  def user_id
    1
  end

  def import_measurements
    ActiveRecord::Base.connection.execute("delete from measurements where measurement_import_id = #{id}")
    ActiveRecord::Base.connection.execute("insert into measurements
                             (user_id, value, unit, created_at, updated_at, captured_at,
                             measurement_import_id, md5sum, location)
                             select #{user_id},alt_reading_value,'cpm', created_at, updated_at, reading_date,
                             #{id}, md5sum, location
                             from drive_logs WHERE
                             drive_import_id = #{id}")
  end

  def add_measurements_to_map
    ActiveRecord::Base.connection.execute(%[insert into maps_measurements (map_id, measurement_id)
                                select #{@map.id}, id from measurements
                                where measurement_import_id = #{id}])
  end
end
