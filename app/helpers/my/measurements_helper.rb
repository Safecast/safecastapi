module My::MeasurementsHelper
  def default_cities_as_string
    current_user.bgeigie_imports.last.try(:cities_as_string)
  end

  def collect_measurements(measurements)
    measurements.collect do |b|
      point = {
        :lat => b.latitude, 
        :lng => b.longitude
      }
    end
  end
end
