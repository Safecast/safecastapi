class Api::UsersController < Api::ApplicationController
  
  expose(:user) { User.find_by_email(params[:email]) }
  
  def finger
    respond_with user
  end
  
  def create
    u = User.create(:email => params[:email], :name => params[:name], :password => params[:password])
    
    u.save
    
    respond_with u
  end
  
  
  def auth  
    #todo -- authenticate instead of just signing in anyone who has an email address
    result = sign_in user
    
    if result
      output = {:message => "Signed in successfully", :auth_token => result[:authentication_token]}
    else
      output = {:message => "Couldn't sign in"}
    end
    
    respond_with output
  end
  
end
