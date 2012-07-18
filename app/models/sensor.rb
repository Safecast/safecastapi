class Sensor < ActiveRecord::Base
  has_and_belongs_to_many :devices

  validates :manufacturer,  :presence => true
  validates :model,         :presence => true

  #we validate type so that no generic sensors are allowed.
  validates :type,          :presence => true

end
