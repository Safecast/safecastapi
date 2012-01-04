class BgeigieImport < MeasurementImport
  
  def tmp_file
    '/tmp/bgeigie.log'
  end
  
  def process
    strip_comments_from_top_of_file
    result = import_to_bgeigie_logs
    delete_tmp_file
    self.update_attributes({
      :status => 'done',
      :measurements_count => result.cmd_tuples
    })
  end
  
  def create_tmp_file
    
  end
  
  def strip_comments_from_top_of_file
    binding.pry
    system(%Q[cat #{source.path}  | sed "/^#/d" > #{tmp_file}])
  end
  
  def import_to_bgeigie_logs
    self.connection.execute(%Q[
                            COPY bgeigie_logs
                             (device_tag, device_serial_id, captured_at, 
                            cpm, counts_per_five_seconds, total_counts,  
                            cpm_validity, latitude_nmea, 
                            north_south_indicator, longitude_nmea,
                            east_west_indicator, altitude, gps_fix_indicator,
                            horizontal_dilution_of_precision,
                            gps_fix_quality_indicator)
                            FROM '#{tmp_file}' CSV
                            ])
  end
  
  def import_measurements
    CSV.read(source.path).each do |row|
      next if row[0].first == '#'
      binding.pry
      BgeigieLog.create!()
    end
  end
  
  def delete_tmp_file
    File.unlink(tmp_file)
  end
end
