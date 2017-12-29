class DashboardsController < ApplicationController
  def show
    return render 'home/show' unless user_signed_in?
    @unapproved_bgeigie_imports = BgeigieImport.unapproved
  end
end
