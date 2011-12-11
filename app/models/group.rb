class Group < ActiveRecord::Base
  has_many :measurements
  
  belongs_to :user
  
  validates :description, :presence => true
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :description, :device_id, :measurements
    ]))
  end
  
end
