require 'digest/md5'
class DriveLog < ActiveRecord::Base

  def update_md5sum # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/LineLength
    self.md5sum = Digest::MD5.hexdigest(%["#{id}","#{drive_import_id}","#{reading_date}","#{reading_value}","#{unit_id}","#{alt_reading_value}","#{alt_unit_id}",#{rolling_count},#{total_count},"#{latitude}","#{longitude}","#{gps_quality_indicator}","#{satellite_num}","#{gps_precision}","#{gps_altitude}","#{gps_device_name}","#{measurement_type}","#{zoom_7_grid}","#{created_at}","#{updated_at}"])
    # rubocop:enable Metrics/LineLength
    self.save!
  end

  def update_location
    self.location ||= Point.new
    self.location.y = latitude
    self.location.x = longitude
    self.save!
  end

end
