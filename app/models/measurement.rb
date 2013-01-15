class Measurement < ActiveRecord::Base
  
  include MeasurementConcerns
  
  validates :latitude,  :presence => true
  validates :longitude, :presence => true
  validates :value,     :presence => true
  validates :unit,      :presence => true
  
  belongs_to :user
  belongs_to :last_updater, :class_name => "User", :foreign_key => "updated_by"
  before_save :set_md5sum
  
  has_and_belongs_to_many :maps
  
  belongs_to :device

  def self.per_page
    100
  end

  def self.nearby_to(lat, lng, distance)
    return scoped unless lat.present? && lng.present? && distance.present?
    location = Point.new
    location.x  = lng.to_f
    location.y = lat.to_f
    where("ST_DWithin(location, ?, ?)", location, distance.to_i).
    order("ST_Distance(location, ST_GeomFromText('POINT (#{location.x} #{location.y})')) ASC")

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
      :id, :value, :user_id,
      :unit, :device_id, :location_name, :original_id,
      :captured_at
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
