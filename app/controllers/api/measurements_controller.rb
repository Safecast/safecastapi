##
# The Measurement service facilitates posting and retrieving Safecast Measurements.
# @url /api/measurements
# @topic Measurements
#
class Api::MeasurementsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => [:new, :create, :update]
  layout :choose_layout
  respond_to :csv
  
  ##
  # List all of the *measurement* resources in the Safecast database.  There are a lot of measurements in
  # the system (on the order of millions), so something this general may not actually be what you want.
  #
  # @url [GET] /api/measurements
  #
  # @argument [Integer] user_id Indicate that results should only include measurements created by this user
  #   This can be provided manually, or by calling [GET] /api/users/:id/measurements
  # @argument [Integer] page Results are paginated automatically.  Default is page 1.
  # @argument [Integer] page_size Number of devices to include in one page.  Default is 10.
  # @argument [Double] latitude Latitude of center point
  # @argument [Double] longitude Longitude of center point
  # @argument [Integer] distance Distance in meters within which to include points around the center point.
  #
  def index
    @streaming = true
    if params[:map_id].present?
      @map = Map.find(params[:map_id])
    end
    if params[:user_id].present?
      @user = User.find params[:user_id]
    end
    if @map
      @result = @map.measurements.nearby_to(params[:latitude], params[:longitude], params[:distance]).paginate(:page => params[:page], :per_page => params[:per_page])
    elsif @user
      @result = @user.measurements.nearby_to(params[:latitude], params[:longitude], params[:distance]).paginate(:page => params[:page], :per_page => params[:per_page])
    else
      @result = Measurement.nearby_to(params[:latitude], params[:longitude], params[:distance]).paginate(:page => params[:page], :per_page => params[:per_page])
    end
    
    if params[:since].present?
      cutoff_time = ActiveSupport::TimeZone['UTC'].parse(params[:since])
      @result = @result.where('updated_at > ?', cutoff_time)
    end

    if request.format == :csv
      @result = @result.paginate(:page => 1, :per_page => @result.total_entries)
    end

    respond_with @result
  end
  
  ##
  # Retrieve the *measurement* resource indicated by the provided id.
  #
  # @url [GET] /api/measurements/:id
  #
  # @argument [Integer] user_id Indicate that results should only include measurements created by this user
  #   This can be provided manually, or by calling [GET] /api/users/:id/measurements
  # @argument [Integer] page Results are paginated automatically.  Default is page 1.
  # @argument [Integer] page_size Number of devices to include in one page.  Default is 10.
  #
  def show
    if params[:withHistory].present? and params[:withHistory]
      measurements = Measurement.where("id = #{params[:id]} OR original_id = #{params[:id]}")
      @result = measurements
    else
      measurement = Measurement.most_recent(params[:id])
      @result = measurement
    end
    respond_with @result
  end
  
  def update
    measurement = Measurement.find(params[:id])
    new_measurement = measurement.revise(params[:measurement])

    # respond_with typically doesn't pass the resource for PUT, but since we're being non-destructive, our PUT actually returns a new resource
    # see: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/5199-respond_with-returns-on-put-and-delete-verb#ticket-5199-14
    @result = new_measurement
    respond_with(@result, :location => my_measurement_url(new_measurement)) do |format|
      format.json { render :json => @result.to_json, :status => :accepted }
    end
  end
  
  def add_to_map
    @map = Map.find params[:map_id]
    if params[:id]
      @measurement = Measurement.find(params[:id])
    else
      @measurement = Measurement.create(params[:measurement])
    end
    @map.measurements<< @measurement
    respond_with @measurement, :location => [:api, @measurement]
  end
  
  def new
    @measurement = Measurement.new(:location_name => 'Fukushima City Office')
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
    @result = @measurement
    respond_with @result, :location => [:my, @measurement]
  end

  def count
    @count = {}
    @count[:count] = Measurement.count
    respond_with @count
  end

protected

  def choose_layout
    return 'application' if ['new', 'create'].include?(action_name)
    'api_doc'
  end
  
end
