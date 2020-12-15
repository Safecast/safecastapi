# frozen_string_literal: true

Fabricator(:device_story_comment) do
  content 'This is a test!'
  user_id 1
  device_story_id 1
end
