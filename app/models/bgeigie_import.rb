class BgeigieImport < MeasurementImport

  validates :user, :presence => true
  validates :source, :presence => true

  belongs_to :user
  has_many :bgeigie_logs

  def tmp_file
    '/tmp/bgeigie.log'
  end

  def process
    create_map
    process_source_file_to_hashed_v2_format
    import_to_bgeigie_logs
    infer_lat_lng_into_bgeigie_logs_from_nmea_location
    import_measurements
    add_measurements_to_map
    delete_tmp_file
    self.update_attribute 'status', 'done'
  end

  def create_map
    @map = user.maps.create!({
      :name => 'bGeigie Import',
      :description => 'bGeigie Import'
    })
    self.update_attribute(:map, @map)
  end

  def get_format_processor(first_non_comment_line)
    # we infer the file format version from the csv width,
    # files created with format 1.1 are not correctly detected with
    # this heuristic...
    # we need to take a deeper look at the first line
    # type = version.major * 10 + version.minor

    csv_width_to_type = {13 => 1, 14 => 10, 16 => 12, 15 => 1120}
    first_line = first_non_comment_line.strip.split(',')
    @type = csv_width_to_type[first_line.size]
    if @type == 1120
      if first_line[2] =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/ # this looks like iso8601
        @type = 20
      else
        @type = 11
      end
    end

    case @type
    when 20
      return lambda {|line| line}
    when 12
      return lambda {|line|
        l = line.split(",")
        l[2] = "#{l[1]}T#{l[2]}Z"
        l[1] = nil
        l.compact*","
      }
    when 11
      return lambda {|line|
        l = line.split(",")
        l[2] = "#{l[1]}T#{l[2]}Z"
        l[1] = 911 # fake device id
        l*","
      }
    when 10
      return lambda {|line|
        l = line.split(",")
        l[2] = "#{l[1]}T#{l[2]}Z"
        l[1] = 910 # fake device id
        l.insert(11, 0) # fake altitude
        l*","
      }
    when 1
      return lambda {|line|
        l = line.split(",")
        cpm = l[2].to_f
        [
         "$formatv1",
         901,
         "#{l[1]}T#{l[2]}Z",
         l[2],
         (cpm / 10.0).to_s,
         (cpm * 5.0).to_s,
         "A",
         l[3..6],
         l[10],
        "A",
         l[9],
         1
       ].flatten*","
      }
    end
  end

  def process_source_file_to_hashed_v2_format
    to_v2 = nil
    File::open(source.path) do |f_in|
      File::open(tmp_file, 'w') do |f_out|
        f_in.each do |line|
          next if line =~ /^#/
          line.strip!
          to_v2 = get_format_processor(line) if to_v2.nil?
          p_line = to_v2(line)
          f_out.puts([p_line, Digest::MD5.hexdigest(p_line)]*",")
        end
      end
    end
  end

  def import_to_bgeigie_logs
    self.connection.execute("DROP TABLE IF EXISTS bgeigie_logs_tmp")
    self.connection.execute(%Q[create temporary table bgeigie_logs_tmp (like bgeigie_logs including defaults)])
    self.connection.execute(%Q[
      COPY bgeigie_logs_tmp (device_tag, device_serial_id, captured_at,
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
