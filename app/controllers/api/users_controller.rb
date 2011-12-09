class Api::UsersController < Api::ApplicationController
  
  expose(:user) { User.find_by_email(params[:email]) }
  
  def finger
    respond_with user
  end
  
  def create
    u = User.create(:email => params[:email], :name => params[:name], :password => params[:password])
    begin
      u.save!
      output = {:message => "User created successfully", :login => u[:email], :auth_key => u[:authentication_token]}
      render :json => output
    rescue
      render :json => {:errors => u.errors.messages}
    end
  end
  
end
