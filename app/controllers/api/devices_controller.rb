class Api::DevicesController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:device)
  
  expose(:devices) do
    Device.page(params[:page])
  end
  
  def index
    respond_with devices
  end
  
  def show
    respond_with device
  end
  
  def create
    device = self.get_or_create(params[:device])
    respond_with device
  end
  
  def get_or_create(dev_params)
    device = Device.new(dev_params)
    if device.valid?
      device.save
    else
      d = Device.where(
        :mfg    => device.mfg,
        :model  => device.model,
        :sensor => device.sensor
      )
      unless d.empty?
        device = d.first
      end
    end
    device
  end
  
end
