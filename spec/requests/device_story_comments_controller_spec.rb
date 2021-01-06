# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeviceStoryCommentsController, type: :request do
  let!(:device_story) { Fabricate(:device_story, last_location_name: 'Israel', device_urn: 'safecast:114699387') }
  let!(:user) { Fabricate(:user) }
  let!(:device_story_comment) { Fabricate(:device_story_comment) }
  describe 'POST #create' do
    WebMock.allow_net_connect!
    it 'creates valid comment' do
      comment_params = {
        content: 'This is a test!',
        device_story_id: DeviceStory.first.id,
        user_id: User.first.id
      }
      expect { post '/device_stories/1/device_story_comments', params: { device_story_comment: comment_params } }.to change { DeviceStoryComment.count }.by(1)
      expect(response.status).to eq 302
    end

    it 'creates invalid comment' do
      comment_params = {
        content: 'a' * 1_001
        device_story_id: DeviceStory.first.id,
        user_id: User.first.id
      }
      expect { post '/device_stories/1/device_story_comments', params: { device_story_comment: comment_params } }.to change { DeviceStoryComment.count }.by(0)
      expect(response.status).to eq 302
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes comment' do
      expect { delete '/device_stories/1/device_story_comments/1' }.to change { DeviceStoryComment.count }.by(-1)
      expect(response.status).to eq 302
    end
  end
end
