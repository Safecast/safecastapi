class Api::MeasurementsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:measurement)
  expose(:measurements) do
    if params[:user_id].present?
      user.measurements
    else
      Measurement.page(params[:page])
    end
  end
  expose(:user) { User.find(params[:user_id]) }
  
  def index
    respond_with measurements
  end
  
  def show
    respond_with measurement
  end
  
  def create
    measurement.user = current_user
    measurement.save
    respond_with measurement, :location => [:api, measurement]
  end
  
end
