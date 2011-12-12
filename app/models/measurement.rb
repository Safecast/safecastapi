class Measurement < ActiveRecord::Base
  
  include MeasurementConcerns
  
  validates :latitude,  :presence => true
  validates :longitude, :presence => true
  validates :value,     :presence => true
  validates :unit,      :presence => true
  
  belongs_to :user
  has_and_belongs_to_many :group
  
  has_one :device
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :value, :user_id, :latitude, :longitude, :unit, :device_id, :group_id,
      :location_name
    ]))
  end
  
end
