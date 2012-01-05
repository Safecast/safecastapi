class My::DashboardsController < My::ApplicationController
  
  def show
    @name = 'Paul'
    render :inline => My::Dashboards::Show.new(self).render(render_to_string)
  end
  alias_method :new, :show
  alias_method :index, :show
  
end