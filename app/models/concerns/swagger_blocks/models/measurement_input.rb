module SwaggerBlocks
  module Models
    module MeasurementInput
      extend ActiveSupport::Concern

      included do
        swagger_schema :MeasurementInput do
          property :captured_at do
            key :type, :string
            key :format, :'date-time'
          end
          property :channel_id do
            key :type, :integer
            key :format, :int64
          end
          property :device_id do
            key :type, :integer
            key :format, :int64
          end
          property :devicetype_id do
            key :type, :integer
            key :format, :int64
          end
          property :height do
            key :type, :integer
            key :format, :int64
          end
          property :latitude do
            key :type, :number
            key :format, :double
          end
          property :location_name do
            key :type, :string
          end
          property :longitude do
            key :type, :number
            key :format, :double
          end
          property :measurement_import_id do
            key :type, :integer
            key :format, :int64
          end
          property :radiation do
            key :type, :string
          end
          property :sensor_id do
            key :type, :integer
            key :format, :int64
          end
          property :station_id do
            key :type, :integer
            key :format, :int64
          end
          property :surface do
            key :type, :string
          end
          property :unit do
            key :type, :string
          end
          property :value do
            key :type, :integer
            key :format, :int64
          end
        end
      end
    end
  end
end
