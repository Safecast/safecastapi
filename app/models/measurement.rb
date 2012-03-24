class Measurement < ActiveRecord::Base
  
  include MeasurementConcerns
  
  validates :latitude,  :presence => true
  validates :longitude, :presence => true
  validates :value,     :presence => true
  validates :unit,      :presence => true
  
  belongs_to :user
  belongs_to :last_updater, :class_name => "User", :foreign_key => "updated_by"
  
  
  has_and_belongs_to_many :maps
  
  has_one :device

  def self.nearby_to(lat, lng, distance)
    return self unless lat.present? && lng.present? && distance.present?
    location = Point.new
    location.x  = lng.to_f
    location.y = lat.to_f
    where("ST_DWithin(location, ?, ?)", location, distance.to_i)
  end
  
  def self.grouped_by_hour
    select("date_trunc('hour', captured_at) as date").
    group("date_trunc('hour', captured_at)")
  end
  
  def serializable_hash(options = {})
    options ||= {}
    super(options.merge(:only => [
      :id, :value, :user_id,
      :unit, :device_id, :location_name, :original_id
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
  
end
