class BgeigieImport < MeasurementImport
  
  validates :user, :presence => true
  validates :source, :presence => true
  
  belongs_to :user
  has_many :bgeigie_logs

  scope :unapproved, where(:approved => false)
  scope :awaiting_approval, where(:status => 'awaiting_approval')
  
  store :status_details, :accessors => [
    :process_file,
    :import_bgeigie_logs,
    :compute_latlng,
    :approved_by_moderator,
    :measurements_added,
    :create_map
  ]
  
  def tmp_file
    '/tmp/bgeigie.log'
  end
  
  def confirm_status(item)
    self.status_details[item] = true
    self.save!
  end
  
  def process
    strip_comments_from_top_of_file
    confirm_status(:process_file)
    import_to_bgeigie_logs
    confirm_status(:import_bgeigie_logs)
    infer_lat_lng_into_bgeigie_logs_from_nmea_location
    confirm_status(:compute_latlng)
    self.update_attribute(:status, 'awaiting_approval')
  end

  def approve!
    self.update_attribute :approved, true
    self.delay.finalize!
  end
  
  def finalize!
    import_measurements
    create_map
    add_measurements_to_map
    confirm_status(:create_map)
    confirm_status(:measurements_added)
    self.update_attribute 'status', 'done'
  end
  
  def create_map
    @map = user.maps.create!({
      :name => 'bGeigie Import',
      :description => 'bGeigie Import'
    })
    self.update_attribute(:map, @map)
  end
  
  def strip_comments_from_top_of_file
    system(%Q[cat #{source.path}  | sed "/^#/d" | #{Rails.root.join(
      'script',
      'add_checksum_to_each_line'
      )} > #{tmp_file}])
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
                            gps_fix_quality_indicator,md5sum)
                            FROM '#{tmp_file}' CSV
                            ])
   self.connection.execute(%Q[UPDATE bgeigie_logs_tmp SET bgeigie_import_id = #{self.id}])
   self.connection.execute(%Q[INSERT INTO bgeigie_logs SELECT * FROM bgeigie_logs_tmp where md5sum not in (select md5sum from bgeigie_logs)])
   self.connection.execute("DROP TABLE bgeigie_logs_tmp")
   self.update_attribute(:measurements_count, self.bgeigie_logs.count)
  end
  
  def infer_lat_lng_into_bgeigie_logs_from_nmea_location
    transaction do
      bgeigie_logs.each do |log_entry|
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
  end
  
  def import_measurements
    self.connection.execute("insert into measurements
                             (user_id, value, unit, created_at, updated_at, captured_at,
                             measurement_import_id, md5sum, location)
                             select #{self.user_id},cpm,'cpm', now(), now(), captured_at,
                             #{self.id}, md5sum, computed_location
                             from bgeigie_logs WHERE
                             bgeigie_import_id = #{self.id}
                             and md5sum not in (select md5sum from measurements)")
  end
  
  def add_measurements_to_map
    self.connection.execute(%Q[insert into maps_measurements (map_id, measurement_id)
                                select #{@map.id}, id from measurements
                                where measurement_import_id = #{self.id}])
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
