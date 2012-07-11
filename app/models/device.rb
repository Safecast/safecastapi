class Device < ActiveRecord::Base
  has_many :measurements
  has_and_belongs_to_many :maps

  validates :manufacturer, :presence => true
  validates :model, :presence => true, :uniqueness => { :scope => :manufacturer, :if => Proc.new { |device| device.serial_number == nil } }
  validates :sensor, :presence => true
  validates :serial_number, :uniqueness => { :scope => :manufacturer }
  
  def serializable_hash(options)
    options ||= {}
    super(options.merge(:only => [
      :id, :manufacturer, :model, :sensor, :serial_number
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
        :sensor         => device.sensor,
        :serial_number  => device.serial_number
      )
      unless d.empty?
        device = d.first
      end
    end
    device
  end

  def identifier
    "#{manufacturer} - #{model} (#{sensor})"
  end

  alias :name :identifier

  def self.search_by_params(params)
    search_params = {}

    [:manufacturer, :model, :sensor, :serial_number].each do |field|
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
