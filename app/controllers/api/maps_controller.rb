# The Map is a way to organize Measurements into sets.  Users can create,
# customize, and share their own maps.
# @url /api/maps
# @topic Maps
#
class Api::MapsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:map)
  
  expose(:maps) do
    if params[:user_id].present?
      user.maps
    elsif params[:page].present?
      Map.page(params[:page])
    else
      Map.all
    end
  end
  expose(:user) { User.find(params[:user_id]) }
  
  expose(:measurements)
  expose(:measurement) { Measurement.find(params[:measurement_id]) }
  
  
  ##
  # List the available *maps* in the database.
  #
  # @url [GET] /api/maps
  #
  def index
    respond_with maps
  end
  
  ##
  # Retrieve the *map* resource referenced by the provided id
  #
  # @url [GET] /api/maps/:id
  #
  def show
    respond_with map
  end
  
  def create
    pg = params[:map]
    if pg && pg['device']
      d = Device.get_or_create(pg['device'])
      pg['device_id'] = d.id
      pg.delete('device')
    end
    map = Map.new(pg)
    map.user = current_user
    map.save
    respond_with(:api, map)
  end


  
end
