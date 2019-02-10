# frozen_string_literal: true

class RadiationIndexController < ApplicationController
  def radiation_index
    index = 0
    if params[:index]
      index = 1 if params[:index].to_sym == :minimum
      index = 2 if params[:index].to_sym == :maximum
    end
    @sort_data = read_csv(index)
  end

  private

  def read_csv(index)
    require 'csv'
    @data_path = Rails.root.join('public/system/g20.csv')
    @data = []
    CSV.foreach(@data_path, headers: true) do |row|
      @data << row
    end
    sort_hash(@data[index])
  end

  def sort_hash(hash)
    nils_as_negatives = hash.each_with_object({}) do |(k, v), h|
      v = -1 if v.nil?
      h[k] = v.to_f.round(1)
    end
    nils_as_negatives.sort_by { |_k, v| -v }
  end
end
