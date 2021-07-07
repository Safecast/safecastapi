# frozen_string_literal: true

class DeviceStoriesController < ApplicationController
  has_scope :order

  before_action :authenticate_user!, only: %i(new create edit update destroy)

  layout :current_layout

  def index
    @device_stories = if params[:search].blank?
                        full_table
                      else
                        @search_term = params[:search].downcase
                        get_like_searched_table(@search_term)
                      end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @device_story = if params.key?(:id)
                      DeviceStory.find(params[:id])
                    else
                      DeviceStory.find_by!(device_urn: params[:device_urn])
                    end
    if params.key?(:time_range)
      puts'has time range'
      @device_story.time_range = params[:time_range]
      puts @device_story.time_range
      respond_to do |format|
        format.html 
        format.json { render :show, location: @device_story}
        format.js { render js: 'window.top.location.reload(true);' }
      end
    else
      puts @device_story.time_range
      respond_with @device_story
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def show_airnote
    @device_story = DeviceStory.find_by!(device_urn: params[:device_urn])
    respond_with @device_story
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def get_like_searched_table(search_term)
    apply_scopes(DeviceStory).where('lower(device_urn) LIKE :search OR lower(custodian_name) LIKE :search', search: "%#{search_term}%")
      .or(apply_scopes(DeviceStory).where('CAST(last_seen AS text) LIKE ?', "%#{search_term}%")).page(params[:page]).per(params[:per_page])
  end

  private

  def current_layout
    if params[:fullscr] == 'true'
      'full_width_device_stories'
    else
      'application'
    end
  end

  def full_table
    apply_scopes(DeviceStory).page(params[:page]).per(params[:per_page])
  end
end
