class My::AccountsController < My::ApplicationController

  expose(:user)
  
  def edit
    
  end
  alias_method :show, :edit
  
  
end
