# frozen_string_literal: true

module DeviceStory
  class DevicesController < ApplicationController
    has_scope :order

    def index
      @devices = apply_scopes(::DeviceStory::Device)
        .page(params[:page])
        .per(params[:per_page])
    end
  end
end
