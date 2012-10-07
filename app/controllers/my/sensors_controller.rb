class My::SensorsController < ApplicationController
  def new
    @sensor = Sensor.new
    render 'api/sensors/new'
  end
end
