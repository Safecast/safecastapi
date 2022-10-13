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

  describe 'GET #me' do
    let(:user) { Fabricate(:user, email: 'john_d@example.com') }

    context 'when not sign in' do
      before do
        get :me, params: { locale: 'en-US' }
      end

      it 'return HTTP 401 Unauthorized' do
        expect(response).to redirect_to(new_user_session_path(locale: 'en-US'))
      end
    end

    context 'when sign in' do
      before do
        sign_in user

        get :me
      end

      it 'return user info' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #me', format: :json do
    let(:user) { Fabricate(:user, email: 'john_d@example.com') }

    context 'when not sign in' do
      before do
        get :me, format: :json
      end

      it 'return HTTP 401 Unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when sign in' do
      before do
        sign_in user

        get :me, format: :json
      end

      it 'returns HTTP 200 OK' do
        expect(response).to have_http_status(:ok)
      end

      it 'return user info' do
        expect(JSON.parse(response.body)).to include(
          'authentication_token' => user.authentication_token
        )
      end
    end
  end
end
