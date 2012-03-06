module My
  class ProfilesController < My::ApplicationController
    
    def show
      @user = current_user
    end
    
    def edit
      @user = current_user
    end
    
    def update
      @user = current_user
      if @user.update_attributes(params[:user])
        redirect_to [:my, :profile]
      else
        render :edit
      end
    end
    
  end
end