class UploaderContactHistory < ActiveRecord::Base
  belongs_to :administrator, class_name: 'User'
  belongs_to :bgeigie_import

  validates :previous_status, presence: true
end
