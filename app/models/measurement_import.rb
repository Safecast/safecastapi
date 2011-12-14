class MeasurementImport < ActiveRecord::Base
  validates :source, :presence => true

  mount_uploader :source, FileUploader

  after_initialize :set_status

  def set_status
    self.status ||= 'unprocessed'
  end 
end
