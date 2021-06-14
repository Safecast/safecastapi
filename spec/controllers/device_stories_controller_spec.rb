# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoriesController, type: :controller do
  describe 'GET #index' do
    let!(:device_stories) { Fabricate.times(4, :device_story) }

    it 'assigns @device_stories' do
      get :index

      expect(assigns(:device_stories)).to eq(device_stories)
    end
  end
  describe 'GET #show_airnote' do
    let!(:device_story) { Fabricate(:device_story) }

    it 'assigns @device_story' do
      get :show, params: { device_urn: device_story.device_urn }

      expect(assigns(:device_story)).to eq(device_story)
    end
  end
end
