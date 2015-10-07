class AirImportsController < ApplicationController
  def create
    @import = AirImport.new(params[:import])
    @import.user = current_user
    if @import.save
      @import.process_in_background
    end
    respond_with @import
  end
end
