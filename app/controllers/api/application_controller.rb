##
# The Safecast API allows developers and devices to access our measurement database
# @url /api
# @topic Safecast API Root
#
# 
module Api
  class ApplicationController < ::ApplicationController
    respond_to :json, :xml, :safecast_api_v1_json, :safecast_api_v1_xml
    layout false
    
    def index
      render :json => {
        :urls => {
          :bgeigie_imports => api_bgeigie_imports_path(:format => params[:format]),
          :devices => api_devices_path(:format => params[:format]),
          :maps => api_maps_path(:format => params[:format]),
          :measurements => api_measurements_path(:format => params[:format]),
          :users => api_users_path(:format => params[:format])
        }
      }
    end
    
    protected
    
    def rescue_action(env)
      render :json => "Error", :status => 500
    end
    
  end
end
