class ProfilesController < ApplicationController
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to :dashboard, :locale => @user.default_locale
    else
      render :edit
    end
  end
  
end