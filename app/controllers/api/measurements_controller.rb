class Api::MeasurementsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:measurement)
  
  def show
    respond_with measurement
  end
  
  def create
    measurement.user = current_user
    if measurement.save
      render :json => measurement
    else
      render :json => measurement.errors
    end
  end
  
end
