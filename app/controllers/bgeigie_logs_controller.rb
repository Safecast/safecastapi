# frozen_string_literal: true

class BgeigieLogsController < ApplicationController
  def index
    @bgeigie_import = BgeigieImport.find(params[:bgeigie_import_id])
    respond_with @bgeigie_import.bgeigie_logs
  end
end
