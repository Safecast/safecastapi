# frozen_string_literal: true

class UsersController < ApplicationController
  include HasOrderScope
  include Swagger::Blocks

  before_action :authenticate_user!, only: %i(me)

  has_scope :name do |_controller, scope, value|
    scope.by_name(value)
  end

  swagger_path '/users' do
    operation :get do
      key :summary, 'All Users'
      key :description, 'Returns all users'
      response 200 do
        key :description, 'user response'
        schema do
          key :type, :array
          items do
            key :$ref, :User
          end
        end
      end
    end
  end

  def index
    @users = apply_scopes(User).where.not(confirmed_at: nil).page(params[:page])
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def me
    @user = current_user
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.json
    end
  end
end
