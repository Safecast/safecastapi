class Api::UsersController < Api::ApplicationController

  expose(:user) { User.find_by_email(params[:email]) }
  
  def create
    user = User.create(:email => params[:email], :name => params[:name], :password => params[:password])
    user.save
    respond_with(:api, user)
  end
  
  def auth
    if result
      output = {:message => "Signed in successfully", :api_key => result[:authentication_token]}
    else
      output = {:message => "Couldn't sign in"}
    end
    respond_with output
  end
  
end
