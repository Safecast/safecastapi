ProcessMeasurementImportJob = Struct.new(:import_id) do
  def perform
    MeasurementImport.find(import_id).process
  end
end
