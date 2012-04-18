module Helpers
  def sign_up(email = "paul@rslw.com", name = "Paul Campbell", password = "mynewpassword")
    visit("/")
    click_link("Sign up")
    fill_in("Email", :with => email)
    fill_in("Name", :with => name)
    fill_in("Password", :with => password)
    fill_in("Password confirmation", :with => password)
    click_button("Sign up")
  end
  
  def sign_in(user)
    visit("/")
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_button("Sign in")
    user
  end
  
  def api_get(*args)
    get(*args)
    ActiveSupport::JSON.decode(response.body)
  end

  def api_post(*args)
    post(*args)
    ActiveSupport::JSON.decode(response.body)
  end
end
