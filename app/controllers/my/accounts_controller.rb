class My::AccountsController < ApplicationController

  expose(:user)
  
  def edit
    
  end
  alias_method :show, :edit
  
  
end
