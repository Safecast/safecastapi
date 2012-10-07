Fabricator(:measurement) do
  value '380'
  unit 'cpm'
  longitude '56'
  latitude '-6'
  device { Device.first || Fabricate(:device) }
  sensor { Sensor.first || Fabricate(:sensor) }
end
