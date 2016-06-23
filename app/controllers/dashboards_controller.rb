class DashboardsController < ApplicationController
  def show
    unless user_signed_in?
      render 'home/show'
      return
    end
    @unapproved_bgeigie_imports = BgeigieImport.unapproved
  end

  alias_method :new, :show
  alias_method :index, :show
end
