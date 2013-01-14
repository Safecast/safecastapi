class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @unapproved_bgeigie_imports = BgeigieImport.unapproved
  end

  alias_method :new, :show
  alias_method :index, :show
end