class My::MeasurementsController < ApplicationController

  expose(:measurement)
  
  def new
    render :inline => My::Measurements::New.new(self).render(render_to_string)
  end
  
  def manifest
    render :inline => Mustache.render(render_to_string, measurement.attributes)
  end
  
end
