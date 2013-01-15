require 'iconv'
class BgeigieImport < MeasurementImport
  validates :user, :presence => true, :on => :create
  
  belongs_to :user
  has_many :bgeigie_logs, :dependent => :destroy
  
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

  serialize :credits, Array
  serialize :cities, Array

  default_scope order('created_at desc')

  def self.by_status(status)
    where(:status => status)
  end

  def self.by_user_id(user_id)
    where(:user_id => user_id)
  end

  def conversion
    @conversion ||= Iconv.new('UTF-8//IGNORE', 'UTF-8')
  end

  def convert_string(string)
     conversion.iconv(string + ' ')[0..-2]
  end

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
    confirm_status(:measurements_added)
    self.update_attribute(:status, 'done')
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
    update_attribute(:lines_count, lines_count)
  end

  def is_sane?(line)
    line_items = line.strip.split(',')
    return false unless line_items.length == 15

    #check header
    return false unless line_items[0].eql? '$BMRDD' or line_items[0].eql? '$BGRDD' or line_items[0].eql? '$BNRDD'

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

  def populate_bgeigie_imports_table
    self.connection.execute(%Q[insert into bgeigie_logs (device_tag, device_serial_id, captured_at, cpm, counts_per_five_seconds, total_counts, cpm_validity, latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator, altitude, gps_fix_indicator, horizontal_dilution_of_precision, gps_fix_quality_indicator, created_at, updated_at, bgeigie_import_id, computed_location, md5sum) select distinct bt.device_tag, bt.device_serial_id, bt.captured_at, bt.cpm, bt.counts_per_five_seconds, bt.total_counts, bt.cpm_validity, bt.latitude_nmea, bt.north_south_indicator, bt.longitude_nmea, bt.east_west_indicator, bt.altitude, bt.gps_fix_indicator, bt.horizontal_dilution_of_precision, bt.gps_fix_quality_indicator, bt.created_at, bt.updated_at, bt.bgeigie_import_id, bt.computed_location, bt.md5sum from bgeigie_logs_tmp bt left join bgeigie_logs bl on bl.md5sum = bt.md5sum where bl.md5sum is null])
  end

  def drop_tmp_table
    self.connection.execute("DROP TABLE bgeigie_logs_tmp")
  end
  
  def import_to_bgeigie_logs
    drop_and_create_tmp_table
    puts psql_command
    run_psql_command
    set_bgeigie_import_id
    populate_bgeigie_imports_table
    drop_tmp_table
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
  
  def delete_tmp_file
    File.unlink(tmp_file)
  end
  
  def nmea_to_lat_lng(latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator)
    #algorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html
    
    #protect against buggy nmea values that have negative values
    latitude_nmea = latitude_nmea.abs
    longitude_nmea = longitude_nmea.abs

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
