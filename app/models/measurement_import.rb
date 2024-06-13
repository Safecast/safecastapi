# frozen_string_literal: true

class MeasurementImport < ApplicationRecord
  validates :source, presence: true, on: :create
  validate :uniqueness_of_md5sum
  has_many :measurement_import_logs
  belongs_to :map

  format_dates :timestamps, format: '%Y/%m/%d %H:%M %z'
  mount_uploader :source, FileUploader

  after_initialize :set_default_values
  before_validation :set_md5sum, on: :create

  AVAILABLE_SUBTYPES = %w(None Drive Surface Cosmic).freeze

  def set_default_values
    self.status ||= 'unprocessed'
    self.subtype = AVAILABLE_SUBTYPES[0] unless AVAILABLE_SUBTYPES.include?(subtype)
  end

  def set_md5sum
    self.md5sum = Digest::MD5.hexdigest(source.read)
  end

  private

  def uniqueness_of_md5sum
    bgeigie_import = self.class.unscoped.find_by(md5sum: md5sum)
    errors.add(:md5sum, "is the same as of Bgeigie Import with the ID: #{bgeigie_import.id}") if bgeigie_import.present? && bgeigie_import != self
  end
end
