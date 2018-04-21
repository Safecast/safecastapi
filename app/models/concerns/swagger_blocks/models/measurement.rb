module SwaggerBlocks
  module Models
    module Measurement
      extend ActiveSupport::Concern

      included do
        include Swagger::Blocks

        swagger_schema :Measurement do
          key :required, [:location, :unit, :value]
          property :id do
            key :type, :integer
            key :format, :int64
          end
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
          property :original_id do
            key :type, :integer
            key :format, :int64
          end
          property :sensor_id do
            key :type, :integer
            key :format, :int64
          end
          property :station_id do
            key :type, :integer
            key :format, :int64
          end
          property :unit do
            key :type, :string
          end
          property :user_id do
            key :type, :integer
            key :format, :int64
          end
          property :value do
            key :type, :integer
            key :format, :int64
          end
        end

        include MeasurementInput
      end
    end
  end
end
