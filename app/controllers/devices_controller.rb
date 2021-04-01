# frozen_string_literal: true

##
# The Device service facilitates creation and retrieval of measurement devices.
# @url /api/devices
# @topic Devices
#
class DevicesController < ApplicationController
  has_scope :order
  has_scope :manufacturer do |_controller, scope, value|
    scope.where('manufacturer LIKE ?', "%#{value}%")
  end
  has_scope :model do |_controller, scope, value|
    scope.where('model LIKE ?', "%#{value}%")
  end
  has_scope :sensor do |_controller, scope, value|
    scope.where('sensor LIKE ?', "%#{value}%")
  end
  before_action :authenticate_user!, only: :create

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
    @device = Device.get_or_create(device_params)
    respond_with @device, location: :devices
  end

  private

  def device_params
    params.fetch(:device, {}).permit!
  end
end
