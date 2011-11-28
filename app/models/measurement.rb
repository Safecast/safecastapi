class Measurement < ActiveRecord::Base
  validates :value, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  
  belongs_to :user
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :value, :user_id, :latitude, :longitude
    ]))
  end
  
end
