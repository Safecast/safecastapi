Safecast::Application.routes.draw do
  
  root :to => 'my/dashboards#show'

  resources :posts

  devise_for :users, :controllers => {
    :sessions => "users/sessions"
  }
  devise_scope :user do
    get "/logout" => "devise/sessions#destroy", :as => :logout
  end
  
  resources :maps
  resource :worldmap
  
  namespace :my do
    resource :dashboard
    resource :profile
    
    resources :bgeigie_imports
    resources :maps
    resources :measurements do
      collection do
        get :manifest
      end
    end
  end
  
  namespace :api do
    root :to => "application#index"
    resources :bgeigie_imports
    resources :users do
      resources :measurements
      
      resources :maps do
        resources :measurements
      end
      
      collection do
        get 'finger'
        get 'auth'
      end
    end
    
    resources :devices
    resources :measurements
    
    resources :maps do
      resources :measurements do
        collection do
          post 'add_to_map', :path => ':id/add'
        end
      end
    end

  end
  
  match '/my/measurements/manifest', :to => 'my/dashboards#show'

  match "reading", :to => 'submissions#reading'
  match "device", :to => 'submissions#device'
  match "details", :to => 'submissions#details'
  match "manifest", :to => 'submissions#manifest'
  
  match "/js_templates.js", :to => "js_templates#show"

  match '/'  => 'api/application#options', :via => :options
  match '/' => 'api/application#index', :via => :get
end
