class BgeigieImport < MeasurementImport
  
  validates :user, :presence => true
  
  belongs_to :user
  has_many :bgeigie_logs
  
  def tmp_file
    '/tmp/bgeigie.log'
  end
  
  def process
    strip_comments_from_top_of_file
    import_to_bgeigie_logs
    infer_lat_lng_into_bgeigie_logs_from_nmea_location
    import_measurements
    delete_tmp_file
    self.update_attribute 'status', 'done'
  end
  
  def create_tmp_file
    
  end
  
  def strip_comments_from_top_of_file
    system(%Q[cat #{source.path}  | sed "/^#/d" > #{tmp_file}])
  end
  
  def import_to_bgeigie_logs
    self.connection.execute("DROP TABLE IF EXISTS bgeigie_logs_tmp")
    self.connection.execute(%Q[create temporary table bgeigie_logs_tmp (like bgeigie_logs including defaults)])
    self.connection.execute(%Q[
                            COPY bgeigie_logs_tmp
                             (device_tag, device_serial_id, captured_at, 
                            cpm, counts_per_five_seconds, total_counts,  
                            cpm_validity, latitude_nmea, 
                            north_south_indicator, longitude_nmea,
                            east_west_indicator, altitude, gps_fix_indicator,
                            horizontal_dilution_of_precision,
                            gps_fix_quality_indicator)
                            FROM '#{tmp_file}' CSV
                            ])
   self.connection.execute(%Q[UPDATE bgeigie_logs_tmp SET bgeigie_import_id = #{self.id}])
   self.connection.execute(%Q[INSERT INTO bgeigie_logs SELECT * FROM bgeigie_logs_tmp])
   self.connection.execute("DROP TABLE bgeigie_logs_tmp")
   self.update_attribute(:measurements_count, self.bgeigie_logs.count)
  end
  
  def import_measurements
    execution_result = self.connection.execute("insert into measurements (user_id, value, unit, location, created_at, updated_at) select #{self.user_id},cpm,'cpm', computed_location, now(), now()
                             from bgeigie_logs WHERE bgeigie_import_id = #{self.id}")
  end
  
  def infer_lat_lng_into_bgeigie_logs_from_nmea_location
    bgeigie_logs.each() do |log_entry|
      latlng = nmea_to_lat_lng(
        log_entry.latitude_nmea,
        log_entry.north_south_indicator,
        log_entry.longitude_nmea,
        log_entry.east_west_indicator
      )
      log_entry.computed_location = Point.new
      log_entry.computed_location.x = latlng[:longitude]
      log_entry.computed_location.y = latlng[:latitude]
      log_entry.save
    end
  end
  
  def delete_tmp_file
    File.unlink(tmp_file)
  end
  
  
  private
  
  def nmea_to_lat_lng(latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator)
    #algorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html
    lat_degrees = (latitude_nmea / 100).to_i
    lng_degrees = (longitude_nmea / 100).to_i
    
    lat_decimal = (latitude_nmea % 100) / 60
    lng_decimal = (longitude_nmea % 100) / 60
    
    {
      :latitude => lat_degrees + lat_decimal,
      :longitude => lng_degrees + lng_decimal
    }
  end
  
end
