class My::BgeigieImportsController < My::ApplicationController
  
  def new
    @bgeigie_import = BgeigieImport.new
  end
  
  def show
    @bgeigie_import = current_user.bgeigie_imports.find(params[:id])
  end
  
end