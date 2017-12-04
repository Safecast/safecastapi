class DashboardsController < ApplicationController
  def show
    unless user_signed_in?
      render 'home/show'
      return
    end
    @unapproved_bgeigie_imports = BgeigieImport.unapproved
  end
end
