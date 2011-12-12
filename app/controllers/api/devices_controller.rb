class Api::DevicesController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:device)
  
  expose(:devices) do
    if params[:where].present?
      Device.where(params[:where])
    else
      Device.page(params[:page])
    end
  end
  
  def index
    respond_with devices
  end
  
  def show
    respond_with device
  end
  
  def create
    device = Device.get_or_create(params[:device])
    respond_with device
  end
  

  
end
