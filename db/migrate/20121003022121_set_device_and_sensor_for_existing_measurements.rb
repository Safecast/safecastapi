class SetDeviceAndSensorForExistingMeasurements < ActiveRecord::Migration
  def up
    lnd7317 = Sensor.where(:manufacturer => 'LND', :model => '7317').first
    unless lnd7317
      lnd7317 = Sensor.create!(
        :manufacturer => 'LND',
        :model => '7317',
        :measurement_category => 'radiation',
        :measurement_type => 'alpha, beta, gamma'
      )
    end

    bgeigie = Device.where(:manufacturer => 'Safecast', :model => 'bGeigie').first
    unless bgeigie
      bgeigie = Device.create!(
        :manufacturer => 'Safecast',
        :model => 'bGeigie',
        :sensors => [lnd7317]
      )
    end

    #update all bgeigie import measurements.
    ActiveRecord::Base.connection.execute(%Q[UPDATE "measurements" SET "device_id" = #{bgeigie.id}, "sensor_id" = #{lnd7317.id} WHERE "measurement_import_id" IS NOT NULL])

    generic_device = Device.generic_radiation

    # assign measurements without a device to generic radiation device.
    ActiveRecord::Base.connection.execute(%Q[UPDATE "measurements" SET "device_id" = #{generic_device.id}, "sensor_id" = #{generic_device.sensors.first.id} WHERE "device_id" IS NULL])

    # the rest, do by hand, since the sensors need to be created according to what's in the db.
  end

  def down
    # this is not really reversible since we're losing the old device_id data.
  end
end
