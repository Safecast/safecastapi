class IngestController < ApplicationController
  def index
    @field = params[:field]
    @uploaded_after = params[:uploaded_after]
    @uploaded_before = params[:uploaded_before]
    @area = params[:area]
    ingest_data if @area
    respond_to do |format|
      format.html
      format.csv { generate_csv }
    end
  end

  private

  def ingest_data
    @data = []
    dates = IngestMeasurement.data_for(device_urn: device_ids).select do |data|
      data[@field] && data[:when_captured] >= @uploaded_after && data[:when_captured] <= @uploaded_before
    end
    dates.map { |data| @data << { when_captured: data[:when_captured], value: data[@field], device: data[:device] } }
  end

  def device_ids
    {
      'central_japan' => ['safecast:974587752', 'safecast:479911182', 'safecast:4007513236', 'safecast:374304606', 'safecast:271575163', 'safecast:1162749983'],
      'fukushima' => ['safecast:2651380949', 'safecast:1875225345'],
      'washington' => ['safecast:3937710776', 'safecast:3856112813', 'safecast:2750599726'],
      'boston' => ['safecast:3709008148', 'safecast:154534971'],
      'san_jose' => ['safecast:129232559'],
      'southern_california' => ['safecast:872300871', 'safecast:4267748403', 'safecast:4249659165', 'safecast:4177786812',
                                'safecast:3768313999', 'safecast:3373827677', 'safecast:2670856639', 'safecast:230442684',
                                'safecast:2299238163', 'safecast:2152053642', 'safecast:114699387', 'safecast:1094924990', 'safecast:1045649384']
    }[@area]
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
