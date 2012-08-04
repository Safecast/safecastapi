##
# The Safecast API allows developers and devices to access our measurement database
# @url /api
# @topic Safecast API Root
#
# 
module Api
  class ApplicationController < ::ApplicationController
    respond_to :html, :json, :safecast_api_v1_json 

    before_filter :cors_set_access_control_headers

    def index
      cors_set_access_control_headers
      result = { }
      respond_with @result = @doc 
    end

    def options
      cors_set_access_control_headers
      render :text => '', :content_type => 'application/json'
    end
    
    protected
    
    def rescue_action(env)
      render :json => "Error", :status => 500
    end

    def cors_set_access_control_headers
      if current_user 
        host = request.env['HTTP_ORIGIN']
      else 
        host = request.env['HTTP_ORIGIN']
        unless /safecast.org$/.match host
          host = 'safecast.org'
        end
      end
      headers['Access-Control-Allow-Origin'] = host
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*, X-Requested-With'
      headers['Access-Control-Max-Age'] = '100000'
    end

  end
end
