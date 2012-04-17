class My::BgeigieImportsController < My::ApplicationController

  before_filter :require_moderator, :only => :approve
  skip_before_filter :authenticate_user!, :only => :show

  def index
    @unapproved_bgeigie_imports = BgeigieImport.unapproved.awaiting_approval
    @bgeigie_imports = current_user.bgeigie_imports
  end
  
  def new
    @bgeigie_import = BgeigieImport.new
  end
  
  def show
    @bgeigie_import = BgeigieImport.find(params[:id])
    respond_to do |wants|
      wants.html
      wants.js do
        if @bgeigie_import.bgeigie_logs.any?
          render :partial => 'my/bgeigie_imports/status'
        else
          render :partial => 'my/bgeigie_imports/show'
        end
      end
    end
  end

  def approve
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.approve!
    redirect_to [:my, @bgeigie_import]
  end
  
end