class My::MeasurementsController < ApplicationController

  expose(:measurement)
  
  def new
    render 'my/dashboards/show'
  end
  
end
