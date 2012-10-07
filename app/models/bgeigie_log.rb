class BgeigieLog < ActiveRecord::Base
  include MeasurementConcerns
  belongs_to :bgeigie_import

  scope :chronological, order("captured_at ASC")
  
  def location
    computed_location
  end
  
  def location=(value)
    computed_location=value
  end
end
