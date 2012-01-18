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
  
  # Public: List all devices in the Safecast database
  #
  # page              - Page number to retrieve
  # devices_per_page  - Number of devices to include in one page
  # where             - Hash of search parameters a device must match to be returned:
  #                     :manufacturer - The device's manufacturer
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
  
  
  @api_doc = {
    :test = "An API doc test for Devices"
  }

  
end
