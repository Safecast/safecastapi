module My
  class ApplicationController < ::SiteApplicationController
    before_filter :authenticate_user!
  end
end