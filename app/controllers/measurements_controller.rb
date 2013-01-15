class MeasurementsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :update]

  has_scope :captured_after
  has_scope :captured_before
  has_scope :distance do |controller, scope, value|
    scope.nearby_to(params[:latitude], params[:longitude], params[:distance])
  end
  has_scope :original_id do |controller, scope, value|
    scope.where("original_id = :value OR id = :value", :value => value)
  end
  has_scope :until
  has_scope :user_id do |controller, scope, value|
    scope.where(:user_id => value)
  end
  has_scope :since
  has_scope :limit

  respond_to :html, :json, :csv

  def index
    @filename = "measurements.csv"
    @streaming = true

    @measurements = apply_scopes(Measurement).paginate(
      :page => params[:page],
      :per_page => params[:per_page]
    )

    if request.format == :csv
      @measurements = @measurements.paginate(:page => 1, :per_page => @measurement.total_entries)
    end

    respond_with @measurements
  end
  
  def show
    @measurement = Measurement.most_recent(params[:id])
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
