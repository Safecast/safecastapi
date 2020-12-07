require 'rails_helper'

RSpec.describe "device_story_comments/index", type: :view do
  before(:each) do
    assign(:device_story_comments, [
      DeviceStoryComment.create!(
        content: "MyText",
        device_story: nil,
        user: nil
      ),
      DeviceStoryComment.create!(
        content: "MyText",
        device_story: nil,
        user: nil
      )
    ])
  end

  it "renders a list of device_story_comments" do
    render
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
