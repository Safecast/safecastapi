# frozen_string_literal: true

RSpec.describe Tasks::DeviceStories::UpdateMetadata do
  before do
    stub_request(:get, 'https://tt.safecast.org/devices')
      .to_return(body: file_fixture('device_stories.json').read)
  end

  let!(:device_story) { Fabricate(:device_story, last_location_name: 'Israel', device_urn: 'safecast:114699387') }

  describe '.call' do
    subject { described_class.call }

    it 'imports new device_stories' do
      expect { subject }.to change { DeviceStory.count }.by(2)
      expect(DeviceStory.find_by(device_urn: 'safecast:114699387').attributes)
        .to include('last_location_name' => 'Hollywood LA CA USA',
                    'last_values' => '3.7v 31|32cpm 0.6|0.9|1.6ug/m3',
                    'device_id' => 114_699_387,
                    'custodian_name' => 'Sean/Jory')
    end

    context 'when device_story exists' do
      it 'updates device_story' do
        expect { subject }
          .to change { device_story.reload.last_location_name }
          .from('Israel').to('Hollywood LA CA USA')
      end
    end

    context 'when coordinates are missing' do
      it 'skips device_story' do
        expect(Rails).to receive_message_chain(:logger, :warn)
          .with('Missing points for device_urn[safecast:370900814822]')

        subject

        expect(DeviceStory.find_by(device_urn: 'safecast:370900814822'))
          .to be_nil
      end
    end
  end
end
