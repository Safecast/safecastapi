# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoryCommentsController, type: :controller do
  let(:user) { Fabricate(:user) }
  let(:story) { Fabricate(:device_story) }
  let(:image_file) { fixture_file_upload('files/sample.jpeg') }

  describe '#destroy' do
    before do
      sign_in(user)

      delete :destroy, params: { id: comment.id, device_story_id: story.id }
    end

    context 'when comment has attached image' do
      let(:comment) { Fabricate(:device_story_comment, image: image_file, user: user, device_story: story) }

      it 'should detach attached image' do
        expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(ActiveStorage::Attachment).not_to be_exists
      end
    end
  end
end
