# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #index' do
    let!(:users) { Fabricate.times(3, :user) }

    context 'when order is specified' do
      before do
        users.slice(0..-2).each do |device|
          device.update(measurements_count: rand(1..100))
        end
      end

      it 'orders with null values to last' do
        get :index, params: { order: 'measurements_count asc' }

        expect(assigns(:users).last).to have_attributes(measurements_count: nil)
      end
    end
  end
end
