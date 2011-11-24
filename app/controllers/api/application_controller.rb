module Api
  class ApplicationController < ::ApplicationController
    respond_to :json
    layout false
    
    def rescue_action(env)
      render :json => "Error", :status => 500
    end
  end
end