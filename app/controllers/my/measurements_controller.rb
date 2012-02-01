class My::MeasurementsController < ApplicationController

  expose(:measurement)
  expose(:measurements) { current_user.measurements }
  
  def show
    render :inline => Mustache.render(render_to_string, measurement.serializable_hash)
  end
  
  def index
    @measurements = current_user.measurements.page(params[:page])
  end
  
  def new
    measurement.value = '000'
    measurement.location_name = 'Tokyo'
    measurement.unit = 'cpm'
    render :inline => Mustache.render(render_to_string, measurement.serializable_hash)
  end
  
  def manifest
    render :inline => Mustache.render(render_to_string, measurement.serializable_hash)
  end
end
