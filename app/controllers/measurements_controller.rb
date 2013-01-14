class MeasurementsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :update]

  respond_to :html, :json, :csv

  def index
    @filename = "measurements.csv"
    @streaming = true
    if params[:user_id].present?
      @user = User.find params[:user_id]
    end
    if @user
      @measurements = @user.measurements.nearby_to(params[:latitude], params[:longitude], params[:distance]).paginate(:page => params[:page], :per_page => params[:per_page])
    elsif params[:latitude].present? && params[:longitude].present?
      @measurements = Measurement.nearby_to(params[:latitude], params[:longitude], params[:distance]).paginate(:page => params[:page], :per_page => params[:per_page])
    else
      @measurements = Measurement.scoped
    end
    
    if params[:since].present?
      cutoff_time = ActiveSupport::TimeZone['UTC'].parse(params[:since])
      @measurements = @measurements.where('updated_at > ?', cutoff_time)
    end

    if params[:until].present?
      cutoff_time = ActiveSupport::TimeZone['UTC'].parse(params[:until])
      @measurements = @measurements.where('updated_at < ?', cutoff_time)
    end

    if params[:captured_after].present?
      cutoff_time = ActiveSupport::TimeZone['UTC'].parse(params[:captured_after])
      @measurements = @measurements.where('captured_at > ?', cutoff_time)
    end

    if params[:captured_before].present?
      cutoff_time = ActiveSupport::TimeZone['UTC'].parse(params[:captured_before])
      @measurements = @measurements.where('captured_at < ?', cutoff_time)
    end

    if params[:limit]
      @measurements = @measurements.limit(params[:limit].to_i)
    end

    if request.format == :csv
      @measurements = @measurement.paginate(:page => 1, :per_page => @measurement.total_entries)
    end

    respond_with @measurements
  end
  
  def show
    @measurement = Measurement.find(params[:id])
    respond_with @measurement
  end
  
  def new
    @last_measurement = current_user.measurements.last
    @measurement = if @last_measurement.present?
      @last_measurement.clone
    else
      Measurement.new(
        :latitude => '37.7607226',
        :longitude => '140.47335610000005',
        :location_name => 'Fukushima City Office'
      )
    end
    @measurement.captured_at = Time.now.strftime("%d %B %Y, %H:%M:%S")
  end

  def create
    @map = Map.find params[:map_id] if params[:map_id].present?
    @measurement = Measurement.new(params[:measurement])
    @measurement.user = current_user
    Measurement.transaction do
      @measurement.save
      @measurement.original_id = @measurement.id
      @measurement.save
    end
    @map.measurements<< @measurement if @map   #this could be done by calling add_to_map, but that seems misleading
    respond_with @measurement
  end

  def update
    @measurement = Measurement.find(params[:id])
    @new_measurement = @measurement.revise(params[:measurement])

    # respond_with typically doesn't pass the resource for PUT, but since we're being non-destructive, our PUT actually returns a new resource
    # see: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/5199-respond_with-returns-on-put-and-delete-verb#ticket-5199-14
    respond_with(@new_measurement) do |format|
      format.json { render :json => @new_measurement.to_json, :status => :accepted }
    end
  end

  def count
    @count = {}
    @count[:count] = Measurement.count
    respond_with @count
  end
  
end
