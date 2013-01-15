class MeasurementImport < ActiveRecord::Base
  validates :source, :presence => true

  has_many :measurement_import_logs  
  belongs_to :map

  format_dates :timestamps
  mount_uploader :source, FileUploader

  before_validation :set_md5sum, :on => :create
  after_initialize :set_status

  def set_status
    self.status ||= 'unprocessed'
  end 
  
  def set_md5sum
    self.md5sum = Digest::MD5.hexdigest(source.read)
  end
end
