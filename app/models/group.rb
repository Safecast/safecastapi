class Group < ActiveRecord::Base
  has_many :measurements
  
  belongs_to :user
  
  validates :description, :presence => true
  
end
