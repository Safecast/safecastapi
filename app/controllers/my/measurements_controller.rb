class My::MeasurementsController < ApplicationController
  expose(:measurements) { current_user.measurements }
  
  def show
    @measurement = current_user.measurements.find(params[:id])
  end
  
  def index
    @measurements = current_user.measurements.page(params[:page])
  end
  
end