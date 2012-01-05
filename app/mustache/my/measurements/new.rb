class My::Measurements::New < Mustachio
  def value
    measurement.value || '000'
  end
  
  def location_name
    measurement.location_name || 'Tokyo'
  end
end