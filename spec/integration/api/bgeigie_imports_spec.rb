# frozen_string_literal: true

feature '/bgeigie_imports API endpoint', type: :request do
  before(:each) do
    User.destroy_all
    @user ||= Fabricate(:user,
                        email: 'paul@rslw.com',
                        name: 'Paul Campbell')

    @result ||= api_post('/bgeigie_imports',
                         params: {
                           api_key: @user.authentication_token,
                           bgeigie_import: {
                             source: fixture_file_upload('/bgeigie.log')
                           }
                         },
                         headers: { 'HTTP_ACCEPT' => 'application/json' })
  end

  context 'just an upload' do
    scenario 'response should be unprocessed' do
      expect(@result['id']).not_to be_blank
      expect(@result['status']).to eq('unprocessed')
      expect(@result['md5sum']).to eq('aad36f9743753b490745c9656cd8fc79')
    end
  end

  context 'after processing' do
    before(:each) do
      Delayed::Worker.new.work_off
      BgeigieImport.find_each(&:finalize!)
    end
    let!(:updated_result) do
      api_get(
        "/bgeigie_imports/#{@result['id']}",
        headers: { 'HTTP_ACCEPT' => 'application/json' }
      )
    end

    subject { updated_result }

    scenario 'response should be processed' do
      expect(updated_result['status']).to eq('done')
    end

    scenario 'it should have imported a bunch of measurements' do
      expect(updated_result['measurements_count']).to eq(23)
    end
  end
end
