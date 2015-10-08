class Station < ActiveRecord::Base
  has_many :device_units
end