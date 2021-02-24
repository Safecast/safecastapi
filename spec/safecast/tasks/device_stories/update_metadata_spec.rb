# frozen_string_literal: true

RSpec.describe Tasks::DeviceStories::UpdateMetadata do
  before do
    stub_request(:get, 'https://tt.safecast.org/devices')
      .to_return(body: file_fixture('device_stories.json').read)
  end

  let!(:device_story) { Fabricate(:device_story, custodian_name: 'Rob', device_urn: 'note:dev:864475041076489') }

  describe '.call' do
    subject { described_class.call }

    it 'imports new device_stories' do
      expect { subject }.to change { DeviceStory.count }.by(1)
      expect(DeviceStory.find_by(device_urn: 'note:dev:864475041076489').attributes)
        .to include('device_id' => 1_555_528_602,
                    'custodian_name' => 'Sean Bonner')
    end

    context 'when device_story exists' do
      it 'updates device_story' do
        expect { subject }
          .to change { device_story.reload.custodian_name }
          .from('Rob').to('Sean Bonner')
      end
    end
  end
end
