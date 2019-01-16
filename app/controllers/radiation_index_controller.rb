class RadiationIndexController < ApplicationController
  def radiation_index
    require 'csv'
    @sort_data = read_csv
  end

  private

  def read_csv
    CSV.foreach('c:\test\g20.csv', headers: true) do |row|
      @data = row
    end
    sort_hash(@data)
  end

  def sort_hash(hash)
    unsort_data = hash.each_with_object({}) do |(k, v), h|
      h[k] = v.to_f.round(0)
    end
    unsort_data.sort_by { |_k, v| -v }
  end
end
