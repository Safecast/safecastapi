class Api::UsersController < Api::ApplicationController
  
  expose(:user) { User.find_by_email(params[:email]) }
  
  def finger
    respond_with user
  end
  
end
