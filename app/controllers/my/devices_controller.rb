class My::DevicesController < My::ApplicationController
  def new
    @device = Device.new
    render 'api/devices/new'
  end
end
