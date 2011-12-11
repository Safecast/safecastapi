class Device < ActiveRecord::Base
  has_and_belongs_to_many :measurements
  has_and_belongs_to_many :groups
  
  
  validates :mfg,    :presence => true
  validates :model,  :presence => true, :uniqueness => { :scope => :mfg }
  validates :sensor, :presence => true
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :mfg, :model, :sensor
    ]))
  end
  
end
