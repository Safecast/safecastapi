module MeasurementsHelper
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

  def measurement_nav_li(unit)
    active = if params[:unit].blank?
      unit == :all
    else
      params[:unit] == unit.to_s
    end
    content_tag(:li, :class => ('active' if active)) do
      link_to t("#{unit}"),
              measurements_url(params.merge(:unit => unit))
    end
  end
end