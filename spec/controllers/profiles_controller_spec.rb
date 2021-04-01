# frozen_string_literal: true

RSpec.describe ProfilesController, type: :controller do
  let(:user) { Fabricate(:user, email: 'john_d@example.com') }

  describe 'PATCH #update' do
    before do
      sign_in user
    end

    context 'edit user profile' do
      before do
        patch :update, params: { user: {
          email: 'john.doe@example.com',
          name: 'John Doe',
          time_zone: 'Tokyo',
          default_locale: 'en-US'
        } }

        user.reload
      end

      it 'should update user profile' do
        expect(response).to redirect_to(dashboard_path)
        expect(user.email).to eq('john.doe@example.com')
      end
    end

    context 'change password' do
      before do
        patch :update, params: { user: {
          password: '123456',
          password_confirmation: '123456'
        } }

        user.reload
      end

      it 'should change password' do
        expect(response).to redirect_to(dashboard_path)
        expect(user).to be_valid_password('123456')
      end
    end
  end
end
