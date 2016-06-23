class BgeigieLog < ActiveRecord::Base
  set_rgeo_factory_for_column(:computed_location,
                              RGeo::Geographic.spherical_factory(:srid => 4326))
  include MeasurementConcerns
  #
  # Note
  # in BgeigieImport we have:
  # has_many :bgeigie_logs, :dependent => :delete_all
  # Thus no callbacks are called during the deletion of a BgeigieImport
  #
  belongs_to :bgeigie_import
  
  def location
    computed_location
  end
  
  def location=(value)
    self.computed_location = value
  end

  def usv
    BigDecimal.new(cpm.to_s) / 330
  end
end
