require 'rails_helper'

RSpec.describe "device_story_comments/edit", type: :view do
  before(:each) do
    @device_story_comment = assign(:device_story_comment, DeviceStoryComment.create!(
      content: "MyText",
      device_story: nil,
      user: nil
    ))
  end

  it "renders the edit device_story_comment form" do
    render

    assert_select "form[action=?][method=?]", device_story_comment_path(@device_story_comment), "post" do

      assert_select "textarea[name=?]", "device_story_comment[content]"

      assert_select "input[name=?]", "device_story_comment[device_story_id]"

      assert_select "input[name=?]", "device_story_comment[user_id]"
    end
  end
end
