require 'securerandom'

class AirImport < MeasurementImport
  DATA_MESSAGE = "dat"

  belongs_to :user

  has_many :air_logs

  store :status_details, accessors: [ :measurements_added ]

  def import_measurements
    connection = ActiveRecord::Base.connection.raw_connection
    name = SecureRandom.uuid
    connection.prepare name, <<-SQL
      insert into measurements (user_id, value,       unit, created_at, updated_at, captured_at, measurement_import_id, md5sum, location)
                         select $1,      measurement, unit, now(),      now(),      captured_at, air_import_id,         md5sum, computed_location
                           from air_logs
                          where air_import_id = $2
    SQL
    connection.exec_prepared(name, [user_id, id])
  end

  def finalize!
    import_measurements
    status_details[:measurements_added] = true
    self.status = 'done'
    save
  end

  def process
    lines = 0
    source.read.each_line do |line|
      message = JSON.parse(line)
      process_message(message)
      lines += 1
    end
    self.lines_count = lines
    self.measurements_count = air_logs.count
    save
  end

  private

  def process_message(message)
    return unless message["msg"] == DATA_MESSAGE

    gps = message["gps"]
    gps_attributes = {
        captured_at: Time.parse(gps['date']),
        latitude: gps['lat'],
        longitude: gps['lon'],
        altitude: gps['alt']
    }

    process_measurements(gps_attributes, message["gas"])
    process_measurements(gps_attributes, message["tmp"])
    process_measurements(gps_attributes, message["pm"])
  end

  def process_measurements(gps_attributes, measurements)
    measurements.each do |measurements|
      measurements['ids'].each do |channel, ids|
        [*ids].each_with_index do |id, i|
          device = Device.find(id)
          measurement_value = measurements[channel]
          values = [*measurement_value]
          air_logs.create(gps_attributes.merge(
                              device_id: id,
                              measurement: values[i],
                              unit: device.unit,
                          ))

        end
      end
    end
  end
end
