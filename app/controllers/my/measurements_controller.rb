class My::MeasurementsController < ApplicationController

  expose(:measurement)
  expose(:measurements) { current_user.measurements.page(params[:page]) }
  
  def show
    render :inline => Mustache.render(render_to_string, measurement.attributes)
  end

  def index
    render :inline => Mustache.render(render_to_string, {
      :measurements => measurements.collect { |m| m.attributes }
    })
  end
  
  def new
    render :inline => My::Measurements::New.new(self).render(render_to_string)
  end
  
  def manifest
    render :inline => Mustache.render(render_to_string, measurement.attributes)
  end
  
  def create
    measurement.user = current_user
    if measurement.save
      redirect_to [:my, measurement]
    else
      error_messages = measurement.errors.full_messages.map { |m| {:message => m}}
      render :inline => Mustache.render(render_to_string(:action => :manifest), measurement.attributes.merge({:error_messages => error_messages}))
    end
  end
end
