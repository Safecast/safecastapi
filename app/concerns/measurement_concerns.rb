module MeasurementConcerns
  def latitude
    (self.location ||= Point.new).y
  end
 
  def latitude=(value)
    (self.location ||= Point.new).y = value.to_f
  end
 
  def longitude
    (self.location ||= Point.new).x
  end
 
  def longitude=(value)
    (self.location ||= Point.new).x = value.to_f
  end
end