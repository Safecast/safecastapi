class Measurement < ActiveRecord::Base
  set_rgeo_factory_for_column(:location,
    RGeo::Geographic.spherical_factory(:srid => 4326))

  attr_accessible :value, :unit, :location, :location_name, :device_id, :height, :surface, :radiation, :latitude, :longitude, :captured_at, :devicetype_id, :sensor_id, :channel_id, :station_id
  
  include MeasurementConcerns
  
  validates :location,  :presence => true
  validates :value,     :presence => true
  validates :unit,      :presence => true
  
  belongs_to :user, :counter_cache => true
  belongs_to :device, :counter_cache => true
  belongs_to :measurement_import
  belongs_to :last_updater, :class_name => "User", :foreign_key => "updated_by"
  before_save :set_md5sum
  
  has_and_belongs_to_many :maps  

  format_dates :captured_at, :format => "%Y/%m/%d %H:%M:%S %z"

  def self.per_page
    100
  end

  def self.nearby_to(lat, lng, distance)
    return scoped unless lat.present? && lng.present? && distance.present?
    where("ST_DWithin(location, ST_GeogFromText('POINT (#{lng.to_f} #{lat.to_f})'), ?)", distance.to_i).
    order("ST_Distance(location, ST_GeogFromText('POINT (#{lng.to_f} #{lat.to_f})')) ASC")

  end

  def self.by_unit(unit)
    where(:unit => unit)
  end
  def self.by_height(height)
    where(:height => height)
  end

  def self.by_devicetype_id(devicetype_id)
    where(:devicetype_id => devicetype_id)
  end

    def self.by_sensor_id(sensor_id)
    where(:sensor_id => sensor_id)
  end

    def self.by_channel_id(channel_id)
    where(:channel_id => channel_id)
  end
    def self.by_station-id(station_id)
    where(:station_id => station_id)
  end

  def self.captured_after(time)
    where('captured_at > ?', ActiveSupport::TimeZone['UTC'].parse(time))
  end

  def self.captured_before(time)
    where('captured_at < ?', ActiveSupport::TimeZone['UTC'].parse(time))
  end

  def self.grouped_by_hour
    select("date_trunc('hour', captured_at) as date").
      group("date_trunc('hour', captured_at)")
  end

  def self.since(time)
    where('updated_at > ?', ActiveSupport::TimeZone['UTC'].parse(time))
  end

  def self.until(time)
    where('updated_at < ?', ActiveSupport::TimeZone['UTC'].parse(time))
  end
  
  def set_md5sum
    self.md5sum = Digest::MD5.hexdigest("#{value}#{latitude}#{longitude}#{captured_at}")
  end
  
def serializable_hash(options = {})
   options ||= {}
   super(options.merge(:only => [
     :id, :value, :height, :user_id,
     :unit, :device_id, :location_name, :original_id,
     :captured_at, :devicetype_id, :sensor_id, :channel_id, 
     :station-id
   ], :methods => [:latitude, :longitude]))
 end
  
  
  def revise(new_params)
    new_measurement = self.dup
    new_measurement.original_id = self.id unless new_measurement.original_id
    
    new_measurement.update_attributes(new_params)

    transaction do
      new_measurement.save
      self.expired_at = new_measurement.created_at
      self.replaced_by = new_measurement.id
      self.save
    end
    
    new_measurement
  end
  
  def self.most_recent(original_id)
    Measurement.where(:replaced_by => nil, :original_id => original_id).first
  end

  def clone
    #override clone to remove timestamps, original_id, and expired_at
    attrs = clone_attributes(:read_attribute_before_type_cast)
    attrs.delete(self.class.primary_key)
    attrs.delete 'created_at'
    attrs.delete 'updated_at'
    attrs.delete 'original_id'
    attrs.delete 'replaced_by'
    attrs.delete 'expired_at'
    attrs.delete 'updated_by'
    attrs.delete 'captured_at'
    record = self.class.new
    record.send :instance_variable_set, '@attributes', attrs
    record
  end
  
end