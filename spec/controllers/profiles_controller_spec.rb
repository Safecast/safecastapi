RSpec.describe ProfilesController, type: :controller do
  let(:user) { Fabricate(:user, email: 'john_d@example.com') }

  describe 'PATCH #update' do
    before do
      sign_in user

      patch :update, user: {
        email: 'john.doe@example.com',
        name: 'John Doe',
        time_zone: 'Tokyo',
        default_locale: 'en-US'
      }

      user.reload
    end

    it 'should update user profile' do
      expect(response).to redirect_to(dashboard_path)
      expect(user.email).to eq('john.doe@example.com')
    end
  end
end
