class My::MeasurementsController < ApplicationController
  expose(:measurements) { current_user.measurements }
  
  def show
    @measurement = current_user.measurements.find(params[:id])
  end
  
  def index
    @measurements = current_user.measurements.page(params[:page])
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
    render 'api/measurements/new'
  end
  
end
