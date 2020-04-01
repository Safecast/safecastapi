# frozen_string_literal: true

class IngestMeasurement
  extend ActiveModel::Naming
  include Elasticsearch::Model

  index_name 'ingest-measurements-*'
  document_type '_doc'

  class << self
    def data_for(query)
      search(query: query).results.map(&:_source)
    end
  end
end
