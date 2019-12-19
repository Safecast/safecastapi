# frozen_string_literal: true

module BgeigieImports
  class AutoApprovedController < ApplicationController
    before_filter :authenticate_user!
    before_filter :require_moderator

    def index
      @bgeigie_imports = BgeigieImport.done.where(would_auto_approve: true).page(params[:page])
      respond_with @bgeigie_imports
    end
  end
end
