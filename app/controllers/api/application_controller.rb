module Api
  class ApplicationController < ::ApplicationController
    respond_to :json
    layout false
  end
end