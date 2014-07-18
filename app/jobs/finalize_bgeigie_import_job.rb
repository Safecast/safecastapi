FinalizeBgeigieImportJob = Struct.new(:bgeigie_import_id) do
  def perform
    BgeigieImport.find(bgeigie_import_id).finalize!
  end
end