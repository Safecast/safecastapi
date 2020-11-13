# frozen_string_literal: true

class DeviceStoriesController < ApplicationController
  has_scope :order

  def index
    @search_term = params[:search].downcase
    @device_stories = if params[:search].blank?
                        apply_scopes(DeviceStory).page(params[:page]).per(params[:per_page])
                      else
                        get_searched_table(@search_term)
                      end
  end

  def show
    @device_story = DeviceStory.find(params[:id])
    respond_with @device_story
  end

  def get_searched_table(search_term)
    apply_scopes(DeviceStory).where('lower(device_urn) LIKE :search OR lower(custodian_name) LIKE :search', search: "%#{search_term}%")
      .or(apply_scopes(DeviceStory).where('lower(last_values) LIKE :search OR lower(last_location_name) LIKE :search', search: "%#{search_term}%"))
      .or(apply_scopes(DeviceStory).where('CAST(last_seen AS text) LIKE ?', "%#{search_term}%")).page(params[:page]).per(params[:per_page])
  end
end
