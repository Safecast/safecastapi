class My::Measurements::New < Mustachio
  
  def id
    measurement.id
  end
  
  def value
    measurement.value || '000'
  end
  
  def location_name
    measurement.location_name || 'Tokyo'
  end
  
  def unit
    measurement.unit || 'cpm'
  end
end