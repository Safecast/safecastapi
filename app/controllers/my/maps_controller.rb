class My::MapsController < ApplicationController
  expose(:map)
  
  def new
    render 'my/dashboards/show'
  end
  
  def index
    @maps = current_user.maps
  end
end
