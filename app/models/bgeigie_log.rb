class BgeigieLog < ActiveRecord::Base
  include MeasurementConcerns
  belongs_to :bgeigie_import
  
  def location
    computed_location
  end
end
