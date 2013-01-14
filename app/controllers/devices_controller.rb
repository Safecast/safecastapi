##
# The Device service facilitates creation and retrieval of measurement devices.
# @url /api/devices
# @topic Devices
#
class DevicesController < ApplicationController

  before_filter :authenticate_user!, :only => :create

  def new
    @device = Device.new
  end
  
  def index
    @devices = if params[:where].present?
      Device.where(params[:where])
    else
      Device.page(params[:page] || 1)
    end
    respond_with @devices
  end
  
  def show
    @device = Devide.find(params[:id])
    respond_with @result
  end

  def create
    @device = Device.get_or_create(params[:device])
    respond_with @device
  end
  
end
