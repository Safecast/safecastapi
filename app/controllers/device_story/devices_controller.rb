# frozen_string_literal: true

module DeviceStory
  class DevicesController < ::ApplicationController
    layout 'device_story'

    has_scope :order

    def index
      @devices = apply_scopes(::DeviceStory::Device)
        .page(params[:page]).per(params[:per_page])
      respond_to do |format|
        format.html { render }
        format.json do
          render json: {
            data: {
              devices: @devices,
              page_info: { current_page: @devices.current_page, total_pages: @devices.total_pages, total_count: @devices.total_count }
            }
          }
        end
      end
    end
  end
end
