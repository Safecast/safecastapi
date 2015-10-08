class StationsController < ApplicationController
  before_filter :require_moderator

  def new
    @station = Station.new
  end
end
