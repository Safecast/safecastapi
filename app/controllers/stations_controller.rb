class StationsController < ApplicationController
  before_filter :require_moderator

  def new
    @station = Station.new
  end

  def create
    @station = Station.new(params[:station])
    if @station.save
      redirect_to @station, notice: 'Station was successfully created.'
    else
      render action: "new"
    end
  end

  def show
    @station = Station.find(params[:id])
  end
end
