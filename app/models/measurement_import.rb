class MeasurementImport < ActiveRecord::Base
  validates :source, :presence => true, :on => :create
  validates :md5sum, :uniqueness => true

  has_many :measurement_import_logs  
  belongs_to :map

  format_dates :timestamps, :format => "%Y/%m/%d %H:%M %z"
  mount_uploader :source, FileUploader

  before_validation :set_md5sum, :on => :create
  after_initialize :set_default_values

  def set_default_values
    self.status ||= 'unprocessed'
    self.subtype ||= 'None'
  end

  def set_md5sum
    self.md5sum = Digest::MD5.hexdigest(source.read)
  end
end
