require "rails_helper"

RSpec.describe DeviceStoryCommentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/device_story_comments").to route_to("device_story_comments#index")
    end

    it "routes to #new" do
      expect(get: "/device_story_comments/new").to route_to("device_story_comments#new")
    end

    it "routes to #show" do
      expect(get: "/device_story_comments/1").to route_to("device_story_comments#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/device_story_comments/1/edit").to route_to("device_story_comments#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/device_story_comments").to route_to("device_story_comments#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/device_story_comments/1").to route_to("device_story_comments#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/device_story_comments/1").to route_to("device_story_comments#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/device_story_comments/1").to route_to("device_story_comments#destroy", id: "1")
    end
  end
end
