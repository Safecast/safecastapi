class Device < ActiveRecord::Base
  has_many :measurements
  has_and_belongs_to_many :maps

  has_and_belongs_to_many :sensors

  validates :manufacturer, :presence => true
  validates :model, :presence => true, :uniqueness => { :scope => :manufacturer, :if => Proc.new { |device| device.serial_number == nil } }

  validates :serial_number, :uniqueness => { :scope => :manufacturer }
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :manufacturer, :model, :serial_number
    ]).merge(:include => [:sensors]))
  end
  
  def self.get_or_create(dev_params)
    if dev_params and dev_params.has_key? 'sensors'
      sensor_ids = dev_params.delete 'sensors'
    end

    device = self.new(dev_params)

    if sensor_ids
      sensor_ids.each do |sid|
        device.sensors << Sensor.find(sid)
      end
    end

    if device.valid?
      device.save
    else
      d = self.where(
        :manufacturer   => device.manufacturer,
        :model          => device.model,
        :serial_number  => device.serial_number
      )
      unless d.empty?
        device = d.first
      end
    end
    device
  end

  def identifier
    "#{manufacturer} - #{model} (#{sensors.first.name})"
  end

  alias :name :identifier

  def self.search_by_params(params)
    search_params = {}

    [:manufacturer, :model, :serial_number].each do |field|
      if params[field].present?
        search_params[field] = params[field]
      end
    end

    if search_params.empty?
      Device.page(params[:page] || 1)
    elsif search_params.include? :serial_number
      Device.where(search_params).first
    else
      Device.where(search_params)
    end
  end

end
