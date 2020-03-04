# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStory::DevicesController, type: :controller do
  describe 'GET #index' do
    it 'should be ok' do
      get :index

      expect(response).to be_ok
    end
  end

  describe 'GET #show' do
  end
end
