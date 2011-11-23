module My
  class ApplicationController < ::ApplicationController
    before_filter :authenticate_user!
  end
end