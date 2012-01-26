class MeasurementImport < ActiveRecord::Base
  validates :source, :presence => true
  
  belongs_to :map

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
