class My::MeasurementsController < ApplicationController

  expose(:measurement)
  
  def new
    render 'my/dashboards/show'
  end
  alias_method :index, :new
  
end
