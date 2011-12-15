class Api::MeasurementsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => [:create, :update]
  
  expose(:measurement)
  
  expose(:measurements) do
    if params[:user_id].present?
      user.measurements
    else
      Measurement.all #using Measurement.page(params[:page]) wound up being problematic
    end
  end
  
  expose(:user) { User.find(params[:user_id]) }
  
  expose(:group) do
    if params[:group_id].present?
      Group.find(params[:group_id])
    else
      nil
    end
  end
  
  expose(:groups)
  
  def index
    if group
      respond_with group.measurements
    else
      respond_with measurements
    end
  end
  
  def show
    binding.pry
    respond_with measurement
  end
  
  def update
    measurement = Measurement.find(params[:id])
    new_measurement = measurement.dup
    
    
    binding.pry
    respond_with new_measurement
  end
  
  def add_to_group
    group.measurements<< measurement if group
    respond_with measurement
  end
  
  def create
    measurement.user = current_user
    measurement.save
    group.measurements<< measurement if group   #this could be done by calling add_to_group, but that seems misleading
    respond_with measurement
  end
  
  
end
