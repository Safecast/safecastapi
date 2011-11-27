class Measurement < ActiveRecord::Base
  validates_presence_of :value
  
  belongs_to :user
  
  def serializable_hash(options = {})
    super(options.merge(:only => [:id, :value, :user_id]))
  end
  
end
