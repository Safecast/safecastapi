class ApiDocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'Safecast API'
      key :description, 'Safecast API'
      contact do
        key :name, 'Safecast'
      end
    end
    key :host, 'api.safecast.org'
    key :basePath, '/api_docs'
  end

  def index
    render json: Swagger::Blocks.build_root_json([UsersController, User, self.class])
  end
end
