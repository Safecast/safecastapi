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
  
  
  def index
    respond_with maps
  end
  
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
