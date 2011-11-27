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
    resources :users do
      collection do
        get "finger"
      end
    end
    resources :measurements
  end
  
  match '/my/measurements/manifest', :to => 'my/dashboards#show'

  match "reading", :to => 'submissions#reading'
  match "device", :to => 'submissions#device'
  match "details", :to => 'submissions#details'
  match "manifest", :to => 'submissions#manifest'

  root :to => 'my/dashboards#show'
end
