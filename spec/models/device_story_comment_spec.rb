# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoryComment, type: :model do
  let(:user) { Fabricate(:user) }
  let(:device_story) { Fabricate(:device_story) }

  describe '#save' do
    let(:comment) { described_class.new(image: upload_file, content: '_content_', user: user, device_story: device_story) }

    context 'with JPEG image' do
      let(:upload_file) { fixture_file_upload('files/sample.jpeg') }

      it 'should have attached image' do
        expect(comment.save).to be_truthy
      end
    end

    context 'with JSON file' do
      let(:upload_file) { fixture_file_upload('files/device_stories.json') }

      it 'should have attached image' do
        expect(comment.save).to be_falsey
        expect(comment.errors.full_messages).to include(match(/Image is invalid type/))
      end
    end
  end
end
