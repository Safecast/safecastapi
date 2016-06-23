# RailsAdmin config file. Generated on July 05, 2013 17:25
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|
  config.main_app_name = ['Safecast', 'Admin']

  config.current_user_method { current_user }
  config.authorize_with do |_controller|
    redirect_to main_app.root_path unless current_user.try(:moderator)
  end

  config.yell_for_non_accessible_fields = false

  config.model 'User' do
    field :email
    field :moderator
    configure :moderator do
      read_only false
    end
  end
end
