# frozen_string_literal: true

# RailsAdmin config file. Generated on July 05, 2013 17:25
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config| # rubocop:disable Metrics/BlockLength
  config.main_app_name = %w(Safecast Admin)

  config.asset_source = :sprockets

  config.current_user_method { current_user }
  config.authorize_with do |_controller|
    redirect_to main_app.root_path unless current_user.try(:moderator)
  end

  # From https://github.com/sferik/rails_admin/wiki/Dashboard-action#disabling-record-count-bars
  config.actions do
    dashboard do
      statistics false
    end
    # collection actions
    index # mandatory
    new
    export
    history_index
    bulk_delete
    # member actions
    show
    edit
    delete
    history_show
    show_in_app
  end

  config.model 'BgeigieLog' do
    list do
      limited_pagination true
    end
  end

  config.model 'Measurement' do
    list do
      limited_pagination true
    end
  end

  config.model 'User' do
    field :email
    field :moderator
    configure :moderator do
      read_only false
    end
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Base
  RailsAdmin::Config::Fields::Types.register(self)
end
# rubocop:enable Style/ClassAndModuleChildren
