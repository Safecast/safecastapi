class BgeigieLog < ActiveRecord::Base
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
