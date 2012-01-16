module Api
  class ApplicationController < ::ApplicationController
    respond_to :json
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