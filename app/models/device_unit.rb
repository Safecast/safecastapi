class DeviceUnit < ActiveRecord::Base
  belongs_to :station
  has_many :device_groups
end
