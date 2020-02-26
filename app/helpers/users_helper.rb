# frozen_string_literal: true

module UsersHelper
  def registering?
    params[:user] && params[:user][:name].present?
  end

  def confirmed_name(user)
    if user.confirmed_at
      user.name
    else
      t('user.unconfirmed_name')
    end
  end
end
