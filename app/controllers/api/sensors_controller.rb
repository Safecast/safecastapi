class Api::SensorsController < Api::ApplicationController
  before_filter :authenticate_user!, :only => :create

  expose(:sensor)

  expose(:sensors) do
    Sensor.search_by_params(params)
  end

  def create
    sensor = Sensor.create(params[:sensor])
    if sensor.errors.empty?
      respond_with sensor, :location => [:new, :my, :device]
    else
      output = {:errors => sensor.errors}
      respond_with output, :location => nil, :status => :unprocessable_entity
    end
  end

  def index
    @result = sensors
    respond_with @result
  end

end
