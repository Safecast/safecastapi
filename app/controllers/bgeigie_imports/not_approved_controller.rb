# frozen_string_literal: true

module BgeigieImports
  class NotApprovedController < ApplicationController
    before_action :authenticate_user!
    before_action :require_moderator

    def index
      @bgeigie_imports = BgeigieImport.submitted.unapproved.page(params[:page])
      respond_with @bgeigie_imports
    end
  end
end
