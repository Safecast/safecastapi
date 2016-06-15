class Admin < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # TODO: remove later
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  def identifier
    email
  end
end
