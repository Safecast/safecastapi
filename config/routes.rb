# frozen_string_literal: true

Safecast::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  scope '(:locale)', constraints: { locale: /(en-US|ja)/ } do
    get '/radiation_index' => 'radiation_index#radiation_index'
    root to: 'dashboards#show'
    devise_for :users
    devise_for :admins
    devise_scope :user do
      get '/logout' => 'devise/sessions#destroy', :as => :logout
    end

    resource :home, controller: :home, only: :show
    resource :dashboard, only: %i(show)
    resource :profile

    namespace :bgeigie_imports do
      resources :not_approved, only: :index
      resources :not_processed, only: :index
      resources :awaiting_response, only: :index
    end

    resources :bgeigie_imports do
      resources :bgeigie_logs, only: :index
      member do
        patch :submit
        put :submit
        patch :reject
        patch :unreject
        patch :approve
        patch :fixdrive
        patch :process_button
        patch :send_email
        patch :contact_moderator
        get :kml
        patch :resolve
      end
    end
    resources :devices do
      resources :measurements, only: :index
    end
    resources :measurement_imports do
      resources :measurements, only: :index
    end
    resources :measurements do
      collection do
        get :count
      end
    end
    resources :users do
      resources :measurements, only: :index
    end
  end

  match '/api/*path' => redirect('/%{path}.%{format}'), :format => true, via: %i(get post put delete)
  match '/api/*path' => redirect('/%{path}'), :format => false, via: %i(get post put delete)
  post '/api/measurements' => 'measurements#create'
  post '/api/measurements.(:format)' => 'measurements#create'

  # legacy fixes (maps.safecast.org now redirects to api.safecast.org, so people might be using the old maps.safecast.org/drive/add URI)
  match '/drive/add', to: redirect('/'), via: %i(get)
  match '/count', to: 'measurements#count', via: %i(get)

  resources :api_docs, only: [:index]
end
