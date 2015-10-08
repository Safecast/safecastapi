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

    # TODO include gps data
    gps = message["gps"]

    process_gas(gps, message["gas"])
  end

  def process_gas(gps, gas_measurements)
    gas_measurements.each do |gas_measurement|
      gas_measurement['ids'].each do |channel, id|
        device = Device.find(id)
        air_logs.create(device_id: id, measurement: gas_measurement[channel], unit: device.unit)
      end
    end
  end
end