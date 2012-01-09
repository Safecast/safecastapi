module My
  class ProfilesController < My::ApplicationController
    
    def show
      @user = current_user
    end
    
  end
end