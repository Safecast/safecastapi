class Api::GroupsController < Api::ApplicationController
  
  before_filter :authenticate_user!, :only => :create
  
  expose(:group)
  
  expose(:groups) do
    if params[:user_id].present?
      user.groups
    else
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
    pg = params[:group]
    if pg && pg['device']
      d = Device.get_or_create(pg['device'])
      pg['device_id'] = d.id
      pg.delete('device')
    end
    group = Group.new(pg)
    group.user = current_user
    group.save
    respond_with(:api, group)
  end
  

  
end
