# frozen_string_literal: true

class BgeigieImport < MeasurementImport # rubocop:disable Metrics/ClassLength
  # States:
  # - unprocessed
  # - processed
  # - submitted
  # - approved
  # - done
  include BgeigieImportState

  validates :user, presence: true, on: :create
  validates :cities, presence: true, on: :update
  validates :credits, presence: true, on: :update

  belongs_to :user
  has_many :bgeigie_logs, dependent: :delete_all
  has_many :uploader_contact_histories, dependent: :delete_all

  scope :newest, -> { order('created_at DESC') }
  scope :oldest, -> { order('created_at') }

  %i(submitted processed done).each do |status|
    scope status, -> { where(status: status) }
  end
  scope :unapproved, -> { where(approved: false).where(rejected: false) }

  scope :pending, -> { processed.unapproved }

  store :status_details, accessors: %i(
    process_file
    import_bgeigie_logs
    compute_latlng
    measurements_added
  )

  def self.filter(query)
    where("lower(name) LIKE :query
           OR lower(source) LIKE :query
           OR lower(description) LIKE :query
           OR lower(cities) LIKE :query
           OR lower(credits) LIKE :query", query: "%#{query.downcase}%")
  end

  def self.by_user_name(name)
    where(user: User.by_name(name))
  end

  def self.rejected_by(name)
    where('lower(rejected_by) LIKE ?', "%#{name.downcase}%")
  end

  def self.by_status(status)
    where(status: status)
  end

  def self.by_user_id(user_id)
    where(user_id: user_id)
  end

  def self.by_rejected(rejected)
    where(rejected: rejected)
  end

  def self.uploaded_before(time)
    where('created_at < ?', time)
  end

  def self.uploaded_after(time)
    where('created_at > ?', time)
  end

  def self.by_subtype(type_or_types)
    where(subtype: type_or_types)
  end

  def name
    read_attribute(:name).presence || "bGeigie Import ##{id}"
  end

  def filename
    read_attribute(:source).presence
  end

  def tmp_file
    @tmp_file ||= "/tmp/bgeigie-#{Kernel.rand}"
  end

  def confirm_status(item)
    status_details[item] = true
    save!(validate: false)
  end

  def process
    create_tmp_file
    import_to_bgeigie_logs
    confirm_status(:compute_latlng)
    update_column(:status, 'processed')
    check_auto_approve # check if this drive can be auto approved
    delete_tmp_file
  end

  def process_in_background
    Delayed::Job.enqueue ProcessBgeigieImportJob.new(id)
  end

  def approve!(userinfo)
    update_column(:approved, true)
    update_column(:approved_by, userinfo)
    Delayed::Job.enqueue FinalizeBgeigieImportJob.new(id)
    Notifications.import_approved(self).deliver_later
  end

  def reject!(userinfo)
    update_column(:rejected, true)
    update_column(:rejected_by, userinfo)
    update_column(:status, 'processed')
    Notifications.import_rejected(self).deliver_later
  end

  def unreject!
    update_column(:rejected, false)
    update_column(:rejected_by, nil)
  end

  def send_email(email_body)
    Notifications.send_email(self, email_body).deliver
  end

  def contact_moderator(email_body)
    Notifications.contact_moderator(self, email_body).deliver
  end

  def finalize!
    import_measurements
    update_counter_caches
    confirm_status(:measurements_added)
    update_column(:status, 'done')
  end

  def fixdrive!
    import_measurements_fix
    update_counter_caches
    confirm_status(:measurements_added)
    update_column(:status, 'done')
  end

  def import_measurements_fix
    ActiveRecord::Base.connection.execute(%[
     insert into measurements
     (user_id, value, unit, created_at, updated_at, captured_at,
     measurement_import_id, location)
     select #{user_id},cpm,'cpm', now(), now(), captured_at,
     #{id}, computed_location
     from bgeigie_logs WHERE
     bgeigie_import_id = #{id}])
  end

  def create_tmp_file # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    lines_count = 0
    File.open(tmp_file, 'at:UTF-8') do |file|
      source.read.each_line do |line|
        next if line.first == '#'
        next if line.strip.blank?
        next unless is_sane? line

        begin
          file.write "#{line.strip},#{Digest::MD5.hexdigest(line.strip)}\n"
        rescue # rubocop:disable Style/RescueStandardError
          nil
        end
        lines_count += 1
      end
    end
    update_column(:lines_count, lines_count)
    confirm_status(:process_file)
  end

  def is_sane?(line) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Naming/PredicateName
    line_items = line.strip.split(',')
    return false unless line_items.length >= 13

    # check header
    # rubocop:disable Metrics/LineLength
    return false unless line_items[0].eql?('$BMRDD') || line_items[0].eql?('$BGRDD') || line_items[0].eql?('$BNRDD') || line_items[0].eql?('$BNXRDD') || line_items[0].eql?('$PNTDD')
    # rubocop:enable Metrics/LineLength

    # check for Valid CPM
    return false unless line_items[6].eql?('A') || line_items[6].eql?('V')

    # check for GPS lock
    return false unless line_items[12].eql?('A') || line_items[12].eql?('V')

    # check for date
    begin
      date = DateTime.parse line_items[2]
    rescue ArgumentError
      nil
    end
    return false unless date

    # check for properly formatted floats
    lat = begin
            Float(line_items[7])
          rescue ArgumentError
            nil
          end
    lon = begin
            Float(line_items[9])
          rescue ArgumentError
            nil
          end
    alt = begin
            Float(line_items[11])
          rescue ArgumentError
            nil
          end
    return false unless lat && lon && alt

    # check for proper N/S and E/W
    return false unless line_items[8].eql?('N') || line_items[8].eql?('S')
    return false unless line_items[10].eql?('E') || line_items[10].eql?('W')

    true
  end

  def db_config
    Rails.configuration.database_configuration[Rails.env]
  end

  def psql_command
    # rubocop:disable Metrics/LineLength
    %[psql -U #{db_config['username']} -h #{db_config['host'] || 'localhost'} #{db_config['database']} -p #{db_config['port'] || '5432'} -c "\\copy bgeigie_logs_tmp (device_tag, device_serial_id, captured_at, cpm, counts_per_five_seconds, total_counts,  cpm_validity, latitude_nmea, north_south_indicator, longitude_nmea,  east_west_indicator, altitude, gps_fix_indicator,horizontal_dilution_of_precision,  gps_fix_quality_indicator,md5sum) FROM '#{tmp_file}' CSV"]
    # rubocop:enable Metrics/LineLength
  end

  def run_psql_command
    logger.info { psql_command }
    out = nil
    ENV['PGPASSWORD'] = db_config['password']
    IO.popen(psql_command, err: %i(child out)) do |io|
      out = io.read
    end
    [$CHILD_STATUS, out]
  end

  def drop_and_create_tmp_table
    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS bgeigie_logs_tmp')
    ActiveRecord::Base.connection.execute 'create table bgeigie_logs_tmp (like bgeigie_logs including defaults)'
  end

  def set_bgeigie_import_id
    ActiveRecord::Base.connection.execute(%(UPDATE bgeigie_logs_tmp SET bgeigie_import_id = #{id}))
  end

  def populate_bgeigie_logs_table
    # rubocop:disable Metrics/LineLength
    ActiveRecord::Base.connection.execute(%[insert into bgeigie_logs (device_tag, device_serial_id, captured_at, cpm, counts_per_five_seconds, total_counts, cpm_validity, latitude_nmea, north_south_indicator, longitude_nmea, east_west_indicator, altitude, gps_fix_indicator, horizontal_dilution_of_precision, gps_fix_quality_indicator, created_at, updated_at, bgeigie_import_id, computed_location, md5sum) select distinct bt.device_tag, bt.device_serial_id, bt.captured_at, bt.cpm, bt.counts_per_five_seconds, bt.total_counts, bt.cpm_validity, bt.latitude_nmea, bt.north_south_indicator, bt.longitude_nmea, bt.east_west_indicator, bt.altitude, bt.gps_fix_indicator, bt.horizontal_dilution_of_precision, bt.gps_fix_quality_indicator, bt.created_at, bt.updated_at, bt.bgeigie_import_id, bt.computed_location, bt.md5sum from bgeigie_logs_tmp bt left join bgeigie_logs bl on bl.md5sum = bt.md5sum where bl.md5sum is null])
    # rubocop:enable Metrics/LineLength
  end

  def drop_tmp_table
    ActiveRecord::Base.connection.execute('DROP TABLE bgeigie_logs_tmp')
  end

  def import_to_bgeigie_logs
    drop_and_create_tmp_table
    status, out = run_psql_command
    if status.success?
      process_successful_import_to_tmp_table
    else
      process_unsuccessful_import_to_tmp_table(status, out)
    end
  ensure
    drop_tmp_table
  end

  def process_successful_import_to_tmp_table
    set_bgeigie_import_id
    compute_latlng_from_nmea
    populate_bgeigie_logs_table
    update_column(:measurements_count, bgeigie_logs.count)
    confirm_status(:import_bgeigie_logs)
  end

  def process_unsuccessful_import_to_tmp_table(status, out)
    # TODO: spool logs to another table with error
    logger.error { "Error while importing to tmp table with exit code: #{status.to_i}\n  Output = #{out}" }
    update_columns(rejected: true, rejected_by: out, status: 'processed')
  end

  def compute_latlng_from_nmea # rubocop:disable Metrics/MethodLength
    # a\lgorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html
    # (converted to SQL)
    ActiveRecord::Base.connection.execute(%[
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
    ActiveRecord::Base.connection.execute(%[
      insert into measurements
      (user_id, value, unit, created_at, updated_at, captured_at,
      measurement_import_id, md5sum, location)
      select #{user_id},cpm,'cpm', now(), now(), captured_at,
      #{id}, md5sum, computed_location
      from bgeigie_logs WHERE
      bgeigie_import_id = #{id}])
  end

  def update_counter_caches
    return unless user.present?

    User.reset_counters(user.id, :measurements)
  end

  def delete_tmp_file
    File.unlink(tmp_file)
  end

  def nmea_to_lat_lng(latitude_nmea, _north_south_indicator, longitude_nmea, _east_west_indicator) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # algorithm described at http://notinthemanual.blogspot.com/2008/07/convert-nmea-latitude-longitude-to.html

    # protect against buggy nmea values that have negative values
    latitude_nmea = b.latitude_nmea.abs
    longitude_nmea = b.longitude_nmea.abs

    lat_sign = 1
    lat_sign = -1 if b.north_south_indicator == 'S'

    lng_sign = 1
    lng_sign = -1 if b.east_west_indicator == 'W'

    lat_degrees = (latitude_nmea / 100).to_i
    lng_degrees = (longitude_nmea / 100).to_i

    lat_decimal = (latitude_nmea % 100) / 60
    lng_decimal = (longitude_nmea % 100) / 60

    {
      latitude: (lat_degrees + lat_decimal) * lat_sign,
      longitude: (lng_degrees + lng_decimal) * lng_sign
    }
  end

  def maximum_cpm
    bgeigie_logs.maximum(:cpm)
  end

  def minimum_cpm
    # used to check if the drive contains cpm value lower than or equal to 0
    bgeigie_logs.minimum(:cpm)
  end

  def check_auto_approve
    # run each auto approval rule and
    # update would_auto_approve column based on if all rules passed
    ap_no_zero_cpm
    if auto_apprv_no_zero_cpm
      update_column(:would_auto_approve, true)
    else
      update_column(:would_auto_approve, false)
    end
  end

  def ap_no_zero_cpm
    # update auto_apprv_no_zero_cpm column based on
    # if minimum_cpm is higher than 0
    if minimum_cpm.zero?
      update_column(:auto_apprv_no_zero_cpm, false)
    else
      update_column(:auto_apprv_no_zero_cpm, true)
    end
  end
end
