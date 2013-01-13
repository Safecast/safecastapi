##
# The bGeigie Import facilitates bGeigie log file uploading.  The service
# automatically generates Measurement resources for each measurement in the
# log file, and a Map that contains all of the measurements.
# @url /api/bgeigie_imports
# @topic bGeigie Imports
#
class Api::BgeigieImportsController < Api::ApplicationController
  
  expose(:bgeigie_import)
  expose(:bgeigie_imports) { BgeigieImport.page(params[:page] || 1) }

  def self.doc
    {
      :methods => [
        {
          :method => "GET",
          :description => "Retrieve a collection of bGeigie Import resources",
          :params => {
            :required => [],
            :optional => [
              {
                :id => "Only retrieve the resource with this id"
              }
            ]
          }
        }

      ],
    }
  end

  ##
  # Retrieve the *bgeigie_import* resource referenced by the provided id
  #
  # @url [GET] /api/bgeigie_imports/:id
  #
  # @response_field [String] status The post-processing status of the import
  #
  def show
    @bgeigie_import = BgeigieImport.find(params[:id])
    @result = @bgeigie_import
    respond_with @result
  end


  def index
    @result = bgeigie_imports
    respond_with @result
  end


  
end
