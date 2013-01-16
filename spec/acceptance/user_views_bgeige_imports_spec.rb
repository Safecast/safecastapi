require "spec_helper"

feature "User views bGeigie imports" do
  let!(:user) { Fabricate(:user) }
  let!(:bgeigie_import) { Fabricate(:bgeigie_import, :user => user, :name => 'my import', :status => "done") }

  scenario "viewing bGeigie imports" do
    sign_in(user)
    visit('/')
    click_link("Imports")
    page.should have_content("bgeigie0.log")
  end


 end 
