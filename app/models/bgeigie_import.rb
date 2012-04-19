class BgeigieImport < MeasurementImport
  validates :user, :presence => true
  validates :source, :presence => true
  
  belongs_to :user
  has_many :bgeigie_logs

  scope :unapproved, where(:approved => false)
  
  store :status_details, :accessors => [
    :process_file,
    :import_bgeigie_logs,
    :compute_latlng,
    :measurements_added,
    :create_map
  ]

  serialize :credits, Array
  serialize :cities, Array

  def tmp_file
    @tmp_file ||= "/tmp/bgeigie-#{Kernel.rand}"
  end
  
  def confirm_status(item)
    self.status_details[item] = true
    self.save!
  end

  def queued_for_processing?
    status_details.empty?
  end
  
  def process
    create_tmp_file
    confirm_status(:process_file)
    import_to_bgeigie_logs
    confirm_status(:import_bgeigie_logs)
    infer_lat_lng_into_bgeigie_logs_from_nmea_location
    confirm_status(:compute_latlng)
    self.update_attribute(:status, 'awaiting_approval')
    delete_tmp_file
    Notifications.import_awaiting_approval(self).deliver
  end

  def approve!
    self.update_attribute(:approved, true)
    self.delay.finalize!
    Notifications.import_approved(self).deliver
  end
  
  def finalize!
    import_measurements
    create_map
    add_measurements_to_map
    confirm_status(:create_map)
    confirm_status(:measurements_added)
    self.update_attribute(:status, 'done')
  end
  
  def create_map
    @map = user.maps.create!({
      :name => 'bGeigie Import',
      :description => 'bGeigie Import'
    })
    self.update_attribute(:map, @map)
  end

  def create_tmp_file
    lines_count = 0
    File.open(tmp_file, 'a') do |file|
      source.read.split("\n").each do |line|
        next if line.first == '#'
        file.write "#{line.strip},#{Digest::MD5.hexdigest(line.strip)}\n"
        lines_count += 1
      end
    end
    update_attribute(:lines_count, lines_count)
  end
  
  def import_to_bgeigie_logs
    self.connection.execute("DROP TABLE IF EXISTS bgeigie_logs_tmp")
    conn = ActiveRecord::Base.connection_pool.checkout
    raw  = conn.raw_connection
    raw.exec "create temporary table bgeigie_logs_tmp (like bgeigie_logs including defaults)"
    raw.exec(%Q[
      COPY bgeigie_logs_tmp
       (device_tag, device_serial_id, captured_at, 
      cpm, counts_per_five_seconds, total_counts,  
      cpm_validity, latitude_nmea, 
      north_south_indicator, longitude_nmea,
      east_west_indicator, altitude, gps_fix_indicator,
      horizontal_dilution_of_precision,
      gps_fix_quality_indicator,md5sum)
      FROM STDIN CSV])
    file_contents = File.open(tmp_file, 'r') { |f| f.read }
    file_contents.each_line { |line| raw.put_copy_data line }
    raw.put_copy_end
    while res = raw.get_result do; end # very important to do this after a copy
    raw.exec(%Q[UPDATE bgeigie_logs_tmp SET bgeigie_import_id = #{self.id}])
    raw.exec(%Q[INSERT INTO bgeigie_logs SELECT * FROM bgeigie_logs_tmp where md5sum not in (select md5sum from bgeigie_logs)])
    raw.exec("DROP TABLE bgeigie_logs_tmp")
    self.update_attribute(:measurements_count, self.bgeigie_logs.count)
    ActiveRecord::Base.connection_pool.checkin(conn)
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
    self.connection.execute(%Q[
      insert into measurements
      (user_id, value, unit, created_at, updated_at, captured_at,
      measurement_import_id, md5sum, location)
      select #{self.user_id},cpm,'cpm', now(), now(), captured_at,
      #{self.id}, md5sum, computed_location
      from bgeigie_logs WHERE
      bgeigie_import_id = #{self.id}
      and md5sum not in (select md5sum from measurements)])
  end
  
  def add_measurements_to_map
    self.connection.execute(%Q[
      insert into maps_measurements (map_id, measurement_id)
      select #{@map.id}, id from measurements
      where measurement_import_id = #{self.id}])
  end
  
  def delete_tmp_file
    File.unlink(tmp_file)
  end
  
  def nmea_to_lat_lng(latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator)
    #algorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html

    lat_sign = 1
    if north_south_indicator == 'S'
      lat_sign = -1
    end

    lng_sign = 1
    if east_west_indicator == 'W'
      lng_sign = -1
    end

    lat_degrees = (latitude_nmea / 100).to_i
    lng_degrees = (longitude_nmea / 100).to_i
    
    lat_decimal = (latitude_nmea % 100) / 60
    lng_decimal = (longitude_nmea % 100) / 60
    
    {
      :latitude => (lat_degrees + lat_decimal) * lat_sign,
      :longitude => (lng_degrees + lng_decimal) * lng_sign
    }
  end

  def credits_as_string=(value)
    self.credits = value.split(",").map(&:strip)
  end

  def credits_as_string
    credits.join(", ")
  end

  def cities_as_string=(value)
    self.cities = value.split(",").map(&:strip)
  end

  def cities_as_string
    cities.join(", ")
  end
end
