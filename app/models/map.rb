class Map < ActiveRecord::Base
  
  has_and_belongs_to_many :measurements
  
  has_and_belongs_to_many :device
  
  belongs_to :user

  validates :name,          :presence => true
  validates :description,   :presence => true
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :name, :description, :device_id, :measurements, :user_id
    ]))
  end
  
end
