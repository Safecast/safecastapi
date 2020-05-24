# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DevicesController, type: :controller do
  describe 'GET #index' do
    let!(:devices) { Fabricate.times(4, :device_story) }

    it 'assigns @devices' do
      get :index

      expect(assigns(:devices)).to eq(devices)
    end
  end
end
