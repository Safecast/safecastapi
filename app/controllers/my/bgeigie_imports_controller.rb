class My::BgeigieImportsController < My::ApplicationController
  before_filter :require_moderator, :only => :approve
  skip_before_filter :authenticate_user!, :only => :show

  def new
    @bgeigie_import = BgeigieImport.new
  end
  
  def approve
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.approve!
    redirect_to @bgeigie_import
  end
end