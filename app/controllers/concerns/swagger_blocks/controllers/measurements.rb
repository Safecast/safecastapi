# frozen_string_literal: true

module SwaggerBlocks
  module Controllers
    module Measurements
      extend ActiveSupport::Concern

      included do
        include Swagger::Blocks

        swagger_path '/measurements' do
          operation :get do
            key :summary, 'All Measurements'
            key :description, 'Returns all measurements'
            response 200 do
              key :description, 'measurement response'
              schema do
                key :type, :array
                items do
                  key :'$ref', :Measurement
                end
              end
            end
          end
        end
        swagger_path '/measurements/{id}' do
          operation :get do
            key :summary, 'Find Measurement by ID'
            key :description, 'Return a single measurement'
            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of measurement of fetch'
              key :required, true
              key :type, :integer
              key :format, :int64
            end
            response 200 do
              key :description, 'measurement response'
              schema do
                key :'$ref', :Measurement
              end
            end
          end
        end
        swagger_path '/measurements' do
          operation :post do
            key :summary, 'Add New Measurement'
            key :description, 'Add a new measurement'
            parameter do
              key :name, :measurement
              key :in, :body
              key :description, 'Measurement to add'
              key :required, true
              schema do
                key :'$ref', :MeasurementInput
              end
            end
            response 200 do
              key :description, 'measurement response'
              schema do
                key :'$ref', :Measurement
              end
            end
          end
        end
      end
    end
  end
end
