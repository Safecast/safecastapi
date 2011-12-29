class My::MapsController < ApplicationController
  expose(:map)
  
  def new
    render 'my/dashboards/show'
  end
  alias_method :index, :new
end
