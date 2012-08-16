class Sensor < ActiveRecord::Base
  has_and_belongs_to_many :devices

  validates :manufacturer,  :presence => true
  validates :model,         :presence => true

  #we validate type so that no generic sensors are allowed.
  validates :measurement_type,          :presence => true
  validates :measurement_category,      :presence => true

  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :manufacturer, :model, :measurement_type, :measurement_category
    ]))
  end

  def name
    "#{self.manufacturer} - #{self.model}"
  end
end
