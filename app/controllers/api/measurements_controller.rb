class Api::MeasurementsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:measurement)
  
  def show
    respond_with measurement
  end
  
  def create
    measurement.user = current_user
    measurement.save
    respond_with measurement
  end
  
end
