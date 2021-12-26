# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoryComment, type: :model do
  let(:user) { Fabricate(:user) }
  let(:device_story) { Fabricate(:device_story) }

  describe '#save' do
    let(:comment) { described_class.new(image: upload_file, content: '_content_', user: user, device_story: device_story) }

    # Workaround for ActiveStorage::IntegrityError, see https://github.com/rails/rails/issues/41991
    def file_upload(src, content_type, binary: false)
      path = Rails.root.join(src)
      original_filename = path.basename.to_s

      tempfile = Tempfile.new(original_filename)
      binary ? tempfile.binwrite(path.binread) : tempfile.write(path.read)
      tempfile.rewind

      uploaded_file = Rack::Test::UploadedFile.new(tempfile, content_type, binary, original_filename: original_filename)
      ObjectSpace.define_finalizer(uploaded_file, uploaded_file.class.finalize(tempfile))

      uploaded_file
    end

    context 'with JPEG image' do
      let(:upload_file) { file_upload('spec/fixtures/files/sample.jpeg', 'image/jpeg') }

      it 'should have attached image' do
        expect(comment.save).to be_truthy
      end
    end

    context 'with JSON file' do
      let(:upload_file) { file_upload('spec/fixtures/files/device_stories.json', 'application/json') }

      it 'should have attached image' do
        expect(comment.save).to be_falsey
        expect(comment.errors.full_messages).to include(match(/Image is invalid type/))
      end
    end
  end
end
