require 'elasticsearch'
require 'elasticsearch/dsl'

class IngestMeasurement
  class << self
    include Elasticsearch::DSL
  end

  def self.client
    @client ||= Elasticsearch::Client.new
  end

  def self.data_for_device(device)
    definition = search do
      query do
        term device: device
      end
    end
    client.search body: definition
  end
end
