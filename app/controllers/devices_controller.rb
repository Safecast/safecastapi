##
# The Device service facilitates creation and retrieval of measurement devices.
# @url /api/devices
# @topic Devices
#
class DevicesController < ApplicationController

  has_scope :order
  has_scope :q do |controller, scope, value|
    scope.filter(value)
  end
  before_filter :authenticate_user!, :only => :create

  def new
    @device = Device.new
  end
  
  def index
    @devices = apply_scopes(Device).page(params[:page])
    respond_with @devices
  end
  
  def show
    @device = Device.find(params[:id])
    respond_with @device
  end

  def create
    @device = Device.get_or_create(params[:device])
    respond_with @device, :location => :devices
  end
  
end
