##
# The Safecast API allows developers and devices to access our measurement database
# @url /api
# @topic Safecast API Root
#
# 
module Api
  class ApplicationController < ::ApplicationController
    respond_to :html, :json, :xml, :safecast_api_v1_json, :safecast_api_v1_xml
    layout 'api_doc'

    def self.doc
      {
        :methods => [
          {
            :method => "GET",
            :description => "This is the Safecast API's root URL. It provides information about the API, namely, links to resources.",
            :params => {
              :required => [],
              :optional => []
            }
          }
        ],
      }
    end

    
    def index
      result = {
        :links => [
          { :rel => 'bgeigie_imports',
            :href => api_bgeigie_imports_path(:format => params[:format]) },

          { :rel => 'devices',
            :href => api_devices_path(:format => params[:format]) },

          { :rel => 'maps',
            :href => api_maps_path(:format => params[:format]) },

          { :rel => 'measurements',
            :href => api_measurements_path(:format => params[:format]) },

          { :rel => 'users',
            :href => api_users_path(:format => params[:format]) }
        ]
      }
      respond_with @result = result
    end
    
    protected
    
    def rescue_action(env)
      render :json => "Error", :status => 500
    end
    
  end
end
