module BgeigieImports
  class WaitingForController < ApplicationController
    before_filter :authenticate_user!
    before_filter :require_moderator

    def index
      @bgeigie_imports = BgeigieImport.where(status: :waiting_for).page(params[:page])
      respond_with @bgeigie_imports
    end
  end
end
