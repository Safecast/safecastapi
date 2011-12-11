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
    device.save
    respond_with device
  end
  
end
