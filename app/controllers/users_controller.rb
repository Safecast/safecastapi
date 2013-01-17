class UsersController < ApplicationController

  has_scope :name do |controller, scope, value|
    scope.by_name(value)
  end

  def index
    @users = apply_scopes(User).page(params[:page])
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end


end