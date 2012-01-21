##
# The bGeigie Import facilitates bGeigie log file uploading.  The service
# automatically generates Measurement resources for each measurement in the
# log file, and a Map that contains all of the measurements.
# @url /api/bgeigie_imports
# @topic bGeigie Imports
#
class Api::BgeigieImportsController < Api::ApplicationController
 
  expose(:bgeigie_import)

  ##
  # Retrieve the *bgeigie_import* resource referenced by the provided id
  #
  # @url [GET] /api/bgeigie_imports/:id
  #
  # @response_field [String] status The post-processing status of the import
  #
  def show
    respond_with bgeigie_import
  end
  
  ##
  # Creates a new *bgeigie_import* record based on the file uploaded
  #
  # @url [POST] /api/bgeigie_imports
  #
  # @argument [File] source The source file containing the bgeigie_log
  #
  # @response_field [Integer] id The newly-created import's ID
  # @response_field [String] md5sum The MD5 checksum of the uploaded file
  # @response_field [String] status The current status of the post-processor.
  #   This will be one of: "unprocessed", "processing", or "processed"
  #
  def create
    bgeigie_import.user = current_user
    if bgeigie_import.save
      bgeigie_import.delay.process
      respond_with bgeigie_import, :location => [:api, bgeigie_import]
    else
      respond_with bgeigie_import, :location => [:api, bgeigie_import]
    end
  end
  
end
