# frozen_string_literal: true

class Admin < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  def identifier
    email
  end
end
