# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DevicesController, type: :controller do
  describe 'GET #index' do
    let!(:devices) do
      [1, 2, 3].map do |i|
        Fabricate(:device, manufacturer: "Company-#{i}")
      end
    end

    context 'when order is specified' do
      before do
        devices.slice(0..-2).each do |device|
          device.update(measurements_count: rand(1..100))
        end
      end

      it 'orders with null values to last' do
        get :index, params: { order: 'measurements_count asc' }

        expect(assigns(:devices).last).to have_attributes(measurements_count: nil)
      end
    end
  end
end
