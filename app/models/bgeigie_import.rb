class BgeigieImport < MeasurementImport
  # States:
  # - unprocessed
  # - processed
  # - submitted
  # - approved
  # - done
  include BgeigieImport::StateConcerns

  validates :user, :presence => true, :on => :create
  validates :cities, :presence => true, :on => :update
  validates :credits, :presence => true, :on => :update
  
  belongs_to :user
  has_many :bgeigie_logs, :dependent => :delete_all
  
  scope :newest, order("created_at DESC")
  scope :oldest, order("created_at")
  scope :done, where(:status => "done")
  scope :unapproved, where(:approved => false)

  store :status_details, :accessors => [
    :process_file,
    :import_bgeigie_logs,
    :compute_latlng,
    :measurements_added
  ]

  def self.filter(query)
    where("lower(name) LIKE :query
           OR lower(source) LIKE :query
           OR lower(description) LIKE :query 
           OR lower(cities) LIKE :query
           OR lower(credits) LIKE :query", :query => "%#{query.downcase}%")
  end

  def self.by_status(status)
    where(:status => status)
  end

  def self.by_user_id(user_id)
    where(:user_id => user_id)
  end

  def self.uploaded_before(time)
    where("created_at < ?", time)
  end

  def self.uploaded_after(time)
    where("created_at > ?", time)
  end

  def name
    read_attribute(:name).presence || "bGeigie Import ##{id}"
  end

  def tmp_file
    @tmp_file ||= "/tmp/bgeigie-#{Kernel.rand}"
  end
  
  def confirm_status(item)
    self.status_details[item] = true
    self.save!(:validate => false)
  end
  
  def process
    create_tmp_file
    import_to_bgeigie_logs
    confirm_status(:compute_latlng)
    self.update_column(:status, 'processed')
    delete_tmp_file
  end

  def process_in_background
    Delayed::Job.enqueue ProcessBgeigieImportJob.new(id)
  end

  def approve!
    self.update_column(:approved, true)
    Delayed::Job.enqueue FinalizeBgeigieImportJob.new(id)
    Notifications.import_approved(self).deliver
  end
  
  def finalize!
    import_measurements
    update_counter_caches
    confirm_status(:measurements_added)
    self.update_column(:status, 'done')
  end

  def create_tmp_file
    lines_count = 0
    File.open(tmp_file, 'at:UTF-8') do |file|
      source.read.each_line do |line|
        next if line.first == '#'
        next if line.strip.blank?
        next unless is_sane? line
        file.write "#{line.strip},#{Digest::MD5.hexdigest(line.strip)}\n" rescue nil
        lines_count += 1
      end
    end
    update_column(:lines_count, lines_count)
    confirm_status(:process_file)
  end

  def is_sane?(line)
    line_items = line.strip.split(',')
    return false unless line_items.length >= 13

    #check header
    return false unless line_items[0].eql? '$BMRDD' or line_items[0].eql? '$BGRDD' or line_items[0].eql? '$BNRDD' or line_items[0].eql? '$BNXRDD'

    #check for Valid CPM 
    return false unless line_items[6].eql? 'A' or line_items[6].eql? 'V'
    
    #check for GPS lock
    return false unless line_items[12].eql? 'A' or line_items[12].eql? 'V'

    #check for date
    date = DateTime.parse line_items[2] rescue nil
    return false unless date

    #check for properly formatted floats
    lat = Float(line_items[7]) rescue nil
    lon = Float(line_items[9]) rescue nil
    alt = Float(line_items[11]) rescue nil
    return false unless lat and lon and alt

    #check for proper N/S and E/W
    return false unless line_items[8].eql? 'N' or line_items[8].eql? 'S'
    return false unless line_items[10].eql? 'E' or line_items[10].eql? 'W'

    true
  end

  def db_config
    Rails.configuration.database_configuration[Rails.env]
  end

  def psql_command
    %Q[psql -U #{db_config['username']} -h #{db_config['host'] || 'localhost'} #{db_config['database']} -c "\\copy bgeigie_logs_tmp (device_tag, device_serial_id, captured_at, cpm, counts_per_five_seconds, total_counts,  cpm_validity, latitude_nmea, north_south_indicator, longitude_nmea,  east_west_indicator, altitude, gps_fix_indicator,horizontal_dilution_of_precision,  gps_fix_quality_indicator,md5sum) FROM '#{tmp_file}' CSV"]
  end

  def run_psql_command    
    system(psql_command)
  end

  def drop_and_create_tmp_table
    self.connection.execute("DROP TABLE IF EXISTS bgeigie_logs_tmp")
    self.connection.execute "create table bgeigie_logs_tmp (like bgeigie_logs including defaults)"
  end

  def set_bgeigie_import_id
    self.connection.execute(%Q[UPDATE bgeigie_logs_tmp SET bgeigie_import_id = #{self.id}])
  end

  def populate_bgeigie_logs_table
    self.connection.execute(%Q[insert into bgeigie_logs (device_tag, device_serial_id, captured_at, cpm, counts_per_five_seconds, total_counts, cpm_validity, latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator, altitude, gps_fix_indicator, horizontal_dilution_of_precision, gps_fix_quality_indicator, created_at, updated_at, bgeigie_import_id, computed_location, md5sum) select distinct bt.device_tag, bt.device_serial_id, bt.captured_at, bt.cpm, bt.counts_per_five_seconds, bt.total_counts, bt.cpm_validity, bt.latitude_nmea, bt.north_south_indicator, bt.longitude_nmea, bt.east_west_indicator, bt.altitude, bt.gps_fix_indicator, bt.horizontal_dilution_of_precision, bt.gps_fix_quality_indicator, bt.created_at, bt.updated_at, bt.bgeigie_import_id, bt.computed_location, bt.md5sum from bgeigie_logs_tmp bt left join bgeigie_logs bl on bl.md5sum = bt.md5sum where bl.md5sum is null])
  end

  def drop_tmp_table
    self.connection.execute("DROP TABLE bgeigie_logs_tmp")
  end
  
  def import_to_bgeigie_logs
    drop_and_create_tmp_table
    run_psql_command
    set_bgeigie_import_id
    compute_latlng_from_nmea
    populate_bgeigie_logs_table
    drop_tmp_table
    self.update_column(:measurements_count, self.bgeigie_logs.count)
    confirm_status(:import_bgeigie_logs)
  end

  def compute_latlng_from_nmea
    #a\lgorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html
    # (converted to SQL)
    self.connection.execute(%Q[
      update bgeigie_logs_tmp set computed_location =
        ST_GeogFromText(
          concat(
            'POINT (',
            (
              (floor(abs(longitude_nmea) / 100)
              + 
              (mod(abs(longitude_nmea),100)/60))
              *
              (case when east_west_indicator = 'W' then -1 else  1 end)
            ), ' ',
            (
              (floor(abs(latitude_nmea) / 100)
              + 
              (mod(abs(latitude_nmea),100)/60))
              *
              (case when north_south_indicator = 'S' then -1 else  1 end)
            ), ')'
          )
        );
    ])
  end
  
  def import_measurements
    self.connection.execute(%Q[
      insert into measurements
      (user_id, value, unit, created_at, updated_at, captured_at,
      measurement_import_id, md5sum, location)
      select #{self.user_id},cpm,'cpm', now(), now(), captured_at,
      #{self.id}, md5sum, computed_location
      from bgeigie_logs WHERE
      bgeigie_import_id = #{self.id}])
  end

  def update_counter_caches
    return unless user.present?
    User.reset_counters(user, :measurements)
  end
  
  def delete_tmp_file
    File.unlink(tmp_file)
  end

  def nmea_to_lat_lng(latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator)
    #algorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html
    
    #protect against buggy nmea values that have negative values
    latitude_nmea = b.latitude_nmea.abs
    longitude_nmea = b.longitude_nmea.abs

    lat_sign = 1
    if b.north_south_indicator == 'S'
      lat_sign = -1
    end

    lng_sign = 1
    if b.east_west_indicator == 'W'
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

end
