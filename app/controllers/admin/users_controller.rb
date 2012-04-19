class Admin::UsersController < Dobro::ApplicationController
  before_filter :authenticate_admin!
  before_filter :set_protected_attributes, only: [ :update, :create ]

private
  def set_protected_attributes
    moderator = params[:user].delete(:moderator) == "1"
    current_record.moderator = moderator
  end
end