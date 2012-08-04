##
# The Safecast API allows developers and devices to access our measurement database
# @url /api
# @topic Safecast API Root
#
# 
module Api
  class ApplicationController < ::ApplicationController
    respond_to :html, :json, :safecast_api_v1_json 

    before_filter :cors_set_access_control_headers, :set_doc

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
      return unless request.env['HTTP_ACCEPT'].eql? 'application/json'
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
    
    private
    
    def set_doc
          @doc = {
            :resources => [
              { :resource => 'bgeigie_imports',
                :url => api_bgeigie_imports_url(:locale => nil)
              },
              { :resource => 'devices',
                :url => api_devices_url(:locale => nil)
              },
              { :resource => 'maps',
                :url => api_maps_url(:locale => nil)
              },
              { :resource => 'measurements',
                :url => api_measurements_url(:locale => nil)
              }
            ],
          }
          @schema = {
            "url" => "https://api.safecast.org/schema",
            "1.0" => {
              "bgeigie_import" => {
                "description"   => "Metadata about an import of a bGeigie log file.",
                "mediaType"     => "application/vnd.safecast.bgeigie_import+json;version=1.0",
                "type"          => "object",
                "properties"    => {
                  "source"              => {
                    "type" => "string"
                  },
                  "md5sum"              => {
                    "type" => "string"
                  },
                  "status"              => {
                    "type" => "string"
                  },
                  "measurement_count"   => {
                    "type" => "integer"
                  },
                  "map_id"              => {
                    "type" => "integer"
                  },
                  "user_id"             => {
                    "type" => "integer"
                  }
                }
              },
              "device" => {
                "description"   => "Our representation of a measurement device.",
                "mediaType"     => "application/vnd.safecast.device+json;version=1.0",
                "type"          => "object",
                "properties"    => {
                  "manufacturer"  => {
                    "type" => "string"
                  },
                  "model"         => {
                    "type" => "string"
                  },
                  "sensor"        => {
                    "type" => "integer"
                  },
                }
              },
              "map" => {
                "description"   => "A collection of measurements that share metadata, and potentially also a device.",
                "mediaType"     => "application/vnd.safecast.map+json;version=1.0",
                "type"          => "object",
                "properties"    => {
                  "name"              => {
                    "type" => "string"
                  },
                  "description"              => {
                    "type" => "string"
                  },
                  "user_id"   => {
                    "type" => "integer"
                  },
                  "device_id"              => {
                    "type" => "integer"
                  },
                }
              },
              "measurement" => {
                "description"   => "A Safecast radiation measurement with a geographic location.",
                "mediaType"     => "application/vnd.safecast.measurement+json;version=1.0",
                "type"          => "object",
                "properties"    => {
                  "value"                   => {
                    "type" => "integer"
                  },
                  "unit"                    => {
                    "type" => "string"
                  },
                  "location"                => {
                    "type" => "point"
                  },
                  "location_name"           => {
                    "type" => "string"
                  },
                  "captured_at"             => {
                    "type" => "datetime"
                  },
                  "device_id"               => {
                    "type" => "integer"
                  },
                  "original_id"             => {
                    "type" => "integer"
                  },
                  "expired_at"              => {
                    "type" => "datetime"
                  },
                  "replaced_by"             => {
                    "type" => "integer"
                  },
                  "updated_by"                 => {
                    "type" => "integer"
                  },
                  "user_id"                 => {
                    "type" => "integer"
                  },
                  "measurement_import_id"   => {
                    "type" => "integer"
                  },
                  "md5sum"                  => {
                    "type" => "string"
                  },
                }
              },
            }
          }
        end

  end
end
