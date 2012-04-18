class Device < ActiveRecord::Base
  has_and_belongs_to_many :measurements
  has_and_belongs_to_many :maps
  
  
  validates :manufacturer,    :presence => true
  validates :model,           :presence => true, :uniqueness => { :scope => :manufacturer }
  validates :sensor,          :presence => true
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :manufacturer, :model, :sensor
    ]))
  end
  
  def self.get_or_create(dev_params)
    device = self.new(dev_params)
    if device.valid?
      device.save
    else
      d = self.where(
        :manufacturer   => device.manufacturer,
        :model          => device.model,
        :sensor         => device.sensor
      )
      unless d.empty?
        device = d.first
      end
    end
    device
  end

  def identifier
    "#{manufacturer} - #{model}"
  end
end
