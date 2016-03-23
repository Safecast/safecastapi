class DeviceGroup < ActiveRecord::Base
  belongs_to :device_unit
  has_many :devices
end
