# frozen_string_literal: true

class FinalizeBgeigieImportJob < ApplicationJob
  def perform(bgeigie_import_id)
    BgeigieImport.find(bgeigie_import_id).finalize!
  end
end
