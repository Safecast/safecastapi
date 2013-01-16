class BgeigieLog < ActiveRecord::Base
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
