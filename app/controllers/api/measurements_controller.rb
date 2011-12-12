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
  
  expose(:group) { Group.find(params[:group_id]) }
  
  expose(:groups)
  
  def index
    respond_with measurements
  end
  
  def show
    respond_with measurement
  end
  
  def create
    measurement.user = current_user
    measurement.group_id = params[:group_id] if params[:group_id]
    measurement.save
    respond_with measurement
  end
  
end
