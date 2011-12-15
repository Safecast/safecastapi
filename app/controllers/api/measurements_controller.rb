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
    if params[:withHistory].present? and params[:withHistory]
      measurements = Measurement.where("id = #{params[:id]} OR original_id = #{params[:id]}")
      respond_with measurements
    else
      measurement = Measurement.most_recent(params[:id])
      respond_with measurement
    end
  end
  
  def update
    measurement = Measurement.find(params[:id])
    new_measurement = measurement.revise(params[:measurement])
    
    # respond_with typically doesn't pass the resource for PUT, but since we're being non-destructive, our PUT actually returns a new resource
    # see: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/5199-respond_with-returns-on-put-and-delete-verb#ticket-5199-14
    render :text => new_measurement.to_json, :status => :ok
  end
  
  def add_to_group
    group.measurements<< measurement if group
    respond_with measurement
  end
  
  def create
    measurement.user = current_user
    Measurement.transaction do
      measurement.save
      measurement.original_id = measurement.id
      measurement.save
    end
    group.measurements<< measurement if group   #this could be done by calling add_to_group, but that seems misleading
    respond_with measurement
  end
  
  
end
