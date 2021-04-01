# frozen_string_literal: true

module MeasurementConcerns
  def latitude=(value)
    self.location = "POINT(#{longitude || 0} #{value})"
  end

  def longitude=(value)
    self.location = "POINT(#{value} #{latitude || 0})"
  end

  def latitude
    location.try(:latitude)
  end

  def longitude
    location.try(:longitude)
  end
end
