class BgeigieLog < ActiveRecord::Base
  set_rgeo_factory_for_column(:computed_location,
    RGeo::Geographic.spherical_factory(:srid => 4326))
  include MeasurementConcerns
  belongs_to :bgeigie_import
  
  def location
    computed_location
  end
  
  def location=(value)
    computed_location=value
  end

  def usv
    BigDecimal.new(cpm.to_s) / 330
  end
end
