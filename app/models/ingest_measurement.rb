# frozen_string_literal: true

class IngestMeasurement
  extend ActiveModel::Naming
  include Elasticsearch::Model

  index_name 'ingest-measurements-*'
  document_type ''

  class << self
    def data_for(term)
      search(query: { terms: term }).results.map(&:_source)
    end
  end
end
