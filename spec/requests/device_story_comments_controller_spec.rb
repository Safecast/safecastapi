# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoryCommentsController, type: :request do
  let(:user) { Fabricate(:user) }
  let(:device_story) { Fabricate(:device_story, last_location_name: 'Israel', device_urn: 'safecast:114699387') }

  before do
    sign_in user
  end

  describe 'POST #create' do
    let(:addressable) { Addressable::Template.new('https://{key}.rest.akismet.com/1.1/comment-check') }

    before { stub_request(:post, addressable).to_return(body: 'false') }
    it 'creates valid comment' do
      comment_params = { content: 'This is a test!', user_id: user.id }
      expect { post device_story_device_story_comments_path(device_story_id: device_story.id), params: { device_story_comment: comment_params } }
        .to change { DeviceStoryComment.count }.by(1)
      expect(response.status).to eq 302
      expect(WebMock).to have_requested(:post, addressable)
    end

    it 'creates invalid comment' do
      comment_params = { content: 'a' * 1_001, user_id: user.id }
      expect { post device_story_device_story_comments_path(device_story_id: device_story.id), params: { device_story_comment: comment_params } }
        .to change { DeviceStoryComment.count }.by(0)

      expect { post '/device_stories/1/device_story_comments', params: { device_story_comment: comment_params } }.to change { DeviceStoryComment.count }.by(0)
      expect(response.status).to eq 302
      expect(WebMock).not_to have_requested(:post, addressable)
    end
  end

  describe 'DELETE #destroy' do
    let(:device_story_comment) { Fabricate(:device_story_comment, device_story: device_story, user: user) }

    it 'deletes comment' do
      delete device_story_device_story_comment_path(device_story_id: device_story.id, id: device_story_comment.id)
      expect { device_story_comment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response.status).to eq 302
    end
  end
end
