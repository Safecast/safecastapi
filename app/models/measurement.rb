class Measurement < ActiveRecord::Base
  validates_presence_of :value
  
  belongs_to :user
  
  def serializable_hash(options = {})
    options ||= {}
    options[:only] = [:id, :value, :user_id]
    options[:methods] = []
    super(options)
  end
  
end
