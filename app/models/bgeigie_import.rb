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
    self.connection.execute("insert into measurements (user_id, value, unit, created_at, updated_at) select #{self.user_id},cpm,'cpm', now(), now()
                             from bgeigie_logs WHERE bgeigie_import_id = #{self.id}")
  end
  
  def delete_tmp_file
    File.unlink(tmp_file)
  end
end
