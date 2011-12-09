class My::DashboardsController < My::ApplicationController
  
  def show
    render 'my/dashboards/show'
  end
  alias_method :new, :show
  alias_method :index, :show
  
end
