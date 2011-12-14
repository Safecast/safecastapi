class MeasurementImport < ActiveRecord::Base
  validates :source, :presence => true

  mount_uploader :source, FileUploader
end
