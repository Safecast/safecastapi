# frozen_string_literal: true

class ProcessBgeigieImportJob < ApplicationJob
  def perform(bgeigie_import_id)
    BgeigieImport.find(bgeigie_import_id).process
  end
end
