# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoryCommentsController do
  let(:user) { Fabricate(:user) }
  let(:story) { Fabricate(:device_story) }
  let(:image_file) { fixture_file_upload('files/sample.jpeg') }

  describe '#create' do
    before do
      sign_in(user)

      stub_request(:post, 'https://_key_.rest.akismet.com/1.1/comment-check')

      post :create, params: { device_story_id: story.id, device_story_comment: { user_id: user.id, content: '_updated_content_' } }
    end

    it 'has flash message' do
      expect(flash[:notice]).to eq('Comment successfully submitted!')
    end
  end

  describe '#update' do
    let(:comment) { Fabricate(:device_story_comment, user: user, device_story: story) }

    before do
      sign_in(user)

      patch :update, params: { id: comment.id, device_story_id: story.id, device_story_comment: { user_id: user.id, content: '_updated_content_' } }
    end

    it 'has flash message' do
      expect(flash[:notice]).to eq('device_story_comment was successfully updated.')
    end
  end

  describe '#destroy' do
    before do
      sign_in(user)

      delete :destroy, params: { id: comment.id, device_story_id: story.id }
    end

    context 'when comment has attached image' do
      let(:comment) { Fabricate(:device_story_comment, image: image_file, user: user, device_story: story) }

      it 'has "Comment deleted!" in flash' do
        expect(flash[:notice]).to eq('Comment deleted!')
      end

      it 'should detach attached image' do
        expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(ActiveStorage::Attachment).not_to be_exists
      end
    end
  end
end
