class My::DevicesController < ApplicationController
  def new
    @device = Device.new
    render 'api/devices/new'
  end
end
