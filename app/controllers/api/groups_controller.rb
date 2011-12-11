class Api::GroupsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:group)
  
  expose(:groups) do
    if params[:user_id].present?
      user.groups
    elsif
      Group.page(params[:page])
    end
  end
  
  def index
    respond_with groups
  end
  
  def show
    respond_with group
  end
  
  def create
    group.user = current_user
    group.save
    respond_with group
  end
  

  
end
