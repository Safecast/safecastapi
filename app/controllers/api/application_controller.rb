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
    
    def api_root
      @api_output = {
        :uri => "/api",
        :version => '1.0',
        :required_params => [],
        :optional_params => [],
        
        :status => "Eventually, the discoverable API goes here"
      }
      if request.format == 'text/html'
        api_docs = localize_api_docs_for_html
        binding.pry
        render :inline => Mustache.render(render_to_string(:template => 'api/index'), api_docs)
      else
        respond_with @api_output
      end
    end
    
    private
    
    
    
    def localize_api_docs_for_html
      {
      :resources => [
        {
          :name => "API Docs",
          :description => "API Documentation",
          :uri => "/api/doc/testing",
          :properties => [
            {
              :name => "Dummy Property",
              :description => "The dummy property just shows us what a property looks like."
            },
            {
              :name => "Smarty Property",
              :description => "The smarty property is also pretty dumb."
            }
          ],
          :methods => [
            "GET" => {
              :required_params => [
                {
                  :name => "test",
                  :description => "This is a test required parameter."
                }, 
                {
                  :name => "date",
                  :description => "This is another test required parameter. It should hold a date or something."
                }
              ],
              :optional_params => [
                {
                  :name => "max_distnce",
                  :description => "This is an optional parameter. It should have a max_distance."
                }
              ]  
            },
            "POST" => "Not Supported",
            "PUT" => "Not Supported",
            "DELETE" => "Not Supported"
          ],
          :notes => "Just in case there are additional notes?"
        }
      ]
    }
  end
    
    

    
  end
end