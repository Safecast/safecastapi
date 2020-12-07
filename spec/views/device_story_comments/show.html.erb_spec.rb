require 'rails_helper'

RSpec.describe "device_story_comments/show", type: :view do
  before(:each) do
    @device_story_comment = assign(:device_story_comment, DeviceStoryComment.create!(
      content: "MyText",
      device_story: nil,
      user: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
