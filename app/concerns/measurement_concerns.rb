module MeasurementConcerns
  def latitude=(value)
    self.location = "POINT(#{longitude || 0} #{value})"
  end

  def longitude=(value)
    self.location = "POINT(#{value} #{latitude || 0})"
  end

  def latitude
    location.try(:y)
  end

  def longitude
    location.try(:x)
  end
end
