class My::MeasurementsController < ApplicationController
  expose(:measurements) { current_user.measurements }
  
  def show
    render :inline => Mustache.render(render_to_string, measurement.serializable_hash)
  end
  
  def index
    @measurements = current_user.measurements.page(params[:page])
  end
  
end