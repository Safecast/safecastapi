# frozen_string_literal: true

class DeviceStoriesController < ApplicationController
  has_scope :order

  def index
    @device_stories = apply_scopes(DeviceStory)
      .page(params[:page])
      .per(params[:per_page])
  end
end
