##
# The Device service facilitates creation and retrieval of measurement devices.
# @url /api/devices
# @topic Devices
#
class Api::DevicesController < Api::ApplicationController

  before_filter :authenticate_user!, :only => :create
  
  expose(:device)
  
  expose(:devices) do
    Device.search_by_params(params)
  end
  
  ##
  # List all of the *device* resources in the Safecast database
  #
  # @url [GET] /api/devices
  #
  # @argument [String] where Hash of search parameters a device must match to be returned:
  #   Valid fields in the hash are "manufacturer", "model", and "sensor"
  # @argument [Integer] page Results are paginated 
  # @argument [Integer] page_size Number of devices to include in one page
  #
  def index
    @result = devices
    respond_with @result
  end
  
  ##
  # Retrieve the *device* resource referenced by the provided id
  #
  # @url [GET] /api/devices/:id[.format]
  #
  # @response_field [String] manufacturer The device's manufacturer
  # @response_field [String] model The model number of the device, provided by the manufacturer
  # @response_field [String] sensor The type or model of sensor element used in the device
  #
  def show
    @result = device
    respond_with @result
  end
  
  ##
  # Create a new *device* resource
  #
  # @url [POST] /api/devices
  #
  # @argument [String] manufacturer The device's manufacturer
  # @argument [String] model The model number of the device, provided by the manufacturer
  # @argument [String] sensor The type or model of sensor element used in the device
  def create
    device = Device.get_or_create(params[:device])
    @result = device
    respond_with @result
  end

  private

  def set_doc
    @doc = {
      :name => "Device",
      :description => "A device used to take a measurement.",
      :properties => {
        :manufacturer => {
          :type => "String",
          :description => "The manufacturer of the device."
        },
        :model => {
          :type => "String",
          :description => "The model number (or string) of the device provided by the device's manufacturer."
        },
        :sensor => {
          :type => "String",
          :description => "The model number of the sensing element present in the device."
        }
      }
    }
  end
  
end
