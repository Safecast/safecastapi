# frozen_string_literal: true

module BgeigieImports
  class RejectedImportController < ApplicationController
    before_filter :authenticate_user!
    before_filter :require_moderator

    def index
      @bgeigie_imports = BgeigieImport.where('rejected = true').page(params[:page])
      respond_with @bgeigie_imports
    end
  end
end
