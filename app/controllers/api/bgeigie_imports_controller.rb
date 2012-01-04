class Api::BgeigieImportsController < Api::ApplicationController
 
  expose(:bgeigie_import)
  
  def show
    respond_with bgeigie_import
  end
  
  def create
    bgeigie_import.user = current_user
    if bgeigie_import.save
      bgeigie_import.delay.process
      respond_with bgeigie_import, :location => [:api, bgeigie_import]
    else
      respond_with bgeigie_import, :location => [:api, bgeigie_import]
    end
  end

end
