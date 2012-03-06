class My::MapsController < My::ApplicationController  
  before_filter :get_maps
  
  def show
    @map = current_user.maps.find(params[:id])
  end
  
protected
  def get_maps
    @maps = current_user.maps.page(params[:page])
  end
end
