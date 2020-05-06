# frozen_string_literal: true

feature '/api/users API endpoint', type: :request do
  before(:all) { User.destroy_all }
  before do
    Fabricate(:user, email: 'paul@rslw.com', name: 'Paul Campbell')
  end

  scenario 'create user' do
    post('/users.json', params: {
      user: {
        email: 'kevin@rkn.la',
        name: 'Kevin Nelson',
        password: 'testing123'
      }
    })
    result = ActiveSupport::JSON.decode(response.body)
    expect(result['email']).to eq('kevin@rkn.la')
    expect(result['id']).not_to eq(nil)
    has_auth = result.include?('authentication_token')
    expect(has_auth).to eq(true)
  end
end
