Safecast::Application.routes.draw do

  resources :posts

  devise_for :users, :controllers => {
    :sessions => "users/sessions"
  }
  devise_scope :user do
    get "/logout" => "devise/sessions#destroy", :as => :logout
  end
  
  namespace :my do
    resource :dashboard
    
    resources :measurements
  end
  
  namespace :api do
    resources :bgeigie_imports
    resources :users do
      resources :measurements
      
      resources :groups do
        resources :measurements
      end
      
      collection do
        get 'finger'
        get 'auth'
      end
      
    end
    
    resources :devices
    resources :measurements
    
    resources :groups do
      resources :measurements do
        collection do
          post 'add_to_group', :path => ':id/add'
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

  root :to => 'my/dashboards#show'
end
