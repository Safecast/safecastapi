##
# The Safecast API allows developers and devices to access our measurement database
# @url /api
# @topic Safecast API Root
#
# 
module Api
  class ApplicationController < ::ApplicationController
    respond_to :html, :json, :safecast_api_v1_json 
    layout 'api_doc'

    before_filter :set_doc

    def index
      result = { }
      respond_with @result = result, :template => 'api/application/root'
    end
    
    protected
    
    def rescue_action(env)
      render :json => "Error", :status => 500
    end

    private

    def set_doc
      @doc = {
        :resources => [
          { :resource => 'bgeigie_imports',
            :url => api_bgeigie_imports_path
          },
          { :resource => 'devices',
            :url => api_devices_path
          },
          { :resource => 'maps',
            :url => api_maps_path
          },
          { :resource => 'measurements',
            :url => api_measurements_path
          },
          { :resource => 'users',
            :url => api_users_path
          },
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
