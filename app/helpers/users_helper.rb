# frozen_string_literal: true

module UsersHelper
  def registering?
    params[:user] && params[:user][:name].present?
  end
end
