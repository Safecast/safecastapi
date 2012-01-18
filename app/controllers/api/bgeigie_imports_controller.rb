class Api::BgeigieImportsController < Api::ApplicationController
 
  expose(:bgeigie_import)

  def show
    respond_with bgeigie_import
  end
  
  def create
    bgeigie_import.user = current_user
    if bgeigie_import.save
      bgeigie_import.delay.process
      respond_with bgeigie_import, :location => [:api, bgeigie_import]
    else
      respond_with bgeigie_import, :location => [:api, bgeigie_import]
    end
  end
  
  
  #see api/application_controller.rb for details about @api_doc
  @api_doc = {
    :resources => [
      {
        :name => "b-Geigie Import",
        :description => "This is the database record for b-Geigie files uploaded  by users.",
        :uri => "/api/bgeigie_imports",
        :properties => [
          {
            :name => "id",
            :description => "The import record's unique identifier"
          },
          {
            :name => "status",
            :description => "The status of the post-upload processor."
          },
          {
            :name => "source",
            :description => "The b-Geigie log file."
          }
        ],
        :methods => {
          "GET" => {

          },
          "POST" => {

          }
        }
      },
      {
        :uri => "/api/bgeigie_imports/:id",
        :methods => {
          "GET" => {
            
          },
          "POST" => {
            
          },
          "PUT" => {
            
          }
        }
      },
      
    ],
      
    
  }

end
