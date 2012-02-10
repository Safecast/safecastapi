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
    render :inline => Mustache.render(render_to_string, measurement.serializable_hash.merge!({
      :value => '000',
      :location_name => 'Fukushima, Japan',
      :unit => 'cpm'
    }))
  end
  
  def manifest
    render :inline => Mustache.render(render_to_string, measurement.serializable_hash)
  end
end