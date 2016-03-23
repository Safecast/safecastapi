class AirImportsController < ApplicationController
  def create
    @import = AirImport.new(params[:air_import])
    @import.user = current_user
    if @import.save
      @import.process_in_background
    end
    respond_with @import
  end

  def new
    @import = AirImport.new
  end

  def show
    @import = AirImport.find(params[:id])
    render(:partial => params[:partial]) and return if params[:partial].present?
    respond_with @import
  end
end
