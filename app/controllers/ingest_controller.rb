# frozen_string_literal: true

class IngestController < ApplicationController
  DEVICE_GROUPS = {
    central_japan: %w(
      safecast:974587752 safecast:479911182 safecast:4007513236 safecast:374304606 safecast:271575163
      safecast:1162749983
    ),
    fukushima: %w(safecast:2651380949 safecast:1875225345),
    washington: %w(safecast:3937710776 safecast:3856112813 safecast:2750599726),
    boston: %w(safecast:3709008148 safecast:154534971),
    san_jose: %w(safecast:129232559),
    southern_california: %w(
      safecast:872300871 safecast:4267748403 safecast:4249659165 safecast:4177786812 safecast:3768313999
      safecast:3373827677 safecast:2670856639 safecast:230442684 safecast:2299238163 safecast:2152053642
      safecast:114699387 safecast:1094924990 safecast:1045649384
    )
  }.freeze

  def index
    @area, @field, @uploaded_after, @uploaded_before =
      params.values_at(:area, :field, :uploaded_after, :uploaded_before)
    @data = @area.present? ? ingest_data(@area, @field, @uploaded_after, @uploaded_before) : []
    respond_to do |format|
      format.html
      format.csv { generate_csv }
    end
  end

  private

  def ingest_data(area, field, after, before)
    IngestMeasurement.data_for(data_query(area, field, after, before)).map do |data|
      {
        when_captured: data[:when_captured],
        value: data[field],
        device: data[:device]
      }
    end
  end

  def data_query(area, field, after, before)
    {
      bool: {
        must: [
          { terms: { device_urn: DEVICE_GROUPS[area.to_sym] } },
          { range: { when_captured: { gte: after, lte: before } } }
        ],
        filter: { exists: { field: field } }
      }
    }
  end

  def generate_csv
    @csv_string = CSV.generate do |csv|
      csv << @data.first.keys
      @data.each do |h|
        csv << h.values
      end
    end
    send_data(@csv_string, type: 'text/csv')
  end
end
