# frozen_string_literal: true

ProcessBgeigieImportJob = Struct.new(:bgeigie_import_id) do
  def perform
    BgeigieImport.find(bgeigie_import_id).process
  end
end
