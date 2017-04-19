feature '/bgeigie_imports API endpoint', type: :request do
  before(:each) do
    User.destroy_all
    @user ||= Fabricate(:user,
                        email: 'paul@rslw.com',
                        name: 'Paul Campbell')

    @result ||= api_post('/bgeigie_imports', {
      api_key: @user.authentication_token,
      bgeigie_import: {
        source: fixture_file_upload('/bgeigie.log')
      }
    }, 'HTTP_ACCEPT' => 'application/json')
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
        {},
        'HTTP_ACCEPT' => 'application/json'
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

  # iOS SDCSafecastAPIRouter

  # GET .ImportLogs [:]
  context 'GET /en-US/bgeigie_imports.json' do
    let!(:bgeigie_import) { Fabricate(:bgeigie_import, user: @user, cities: 'Tokyo', credits: 'John Doe') }
    before do
      login_as(@user, scope: :user)

      get '/en-US/bgeigie_imports.json'
    end

    subject { JSON.parse(response.body) }

    it { is_expected.to be_a(Array) }
    it 'should have ISO-8601 format datetime on created_at and updated_at in each item' do
      subject.each do |item|
        expect { parse_iso8601(item['created_at']) }.to_not raise_error
        expect { parse_iso8601(item['updated_at']) }.to_not raise_error
      end
    end
    it 'should have several attributes' do
      subject.each do |item|
        expect(item).to be_key('id')
        expect(item).to be_key('source')
        expect(item['source']).to be_key('url')
        expect(item).to be_key('status_details')
      end
    end

    # Time.xmlschema accepts more formats. We would like to only parse
    # format that Drivecast iOS app accepts.
    def parse_iso8601(date_str)
      Time.strptime(date_str, '%Y-%m-%dT%H:%M:%SZ')
    end
  end

  # PUT .EditImportLogMetadata(let id, _, _, _, _, _)
  #   ["api_key": key, "bgeigie_import[credits]": credits,
  #   "bgeigie_import[cities]": cities, "bgeigie_import[name]": name,
  #   "bgeigie_import[description]": description]
  context 'PUT /bgeigie_imports/:id.json' do
    let!(:bgeigie_import) { Fabricate(:bgeigie_import, user: @user, cities: 'Tokyo', credits: 'John Doe') }
    before do
      login_as(@user, scope: :user)

      put "/en-US/bgeigie_imports/#{bgeigie_import.id}.json", post_params

    end

    it { expect(response.status).to eq(204) } # No Content

    subject { bgeigie_import.reload }

    it { expect(subject.credits).to eq('Jane Doe') }
    it { expect(subject.cities).to eq('Osaka') }
    it { expect(subject.name).to eq('My Import') }
    it { expect(subject.description).to eq('Doh!') }

    def post_params
      {
        # XXX: iOS app sends this, but not necesarry.
        'api_key' => @user.authentication_token,
        'bgeigie_import[credits]' => 'Jane Doe',
        'bgeigie_import[cities]' => 'Osaka',
        'bgeigie_import[name]' => 'My Import',
        'bgeigie_import[description]' => 'Doh!'
      }
    end
  end
end
