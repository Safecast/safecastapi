Safecast::Application.routes.draw do
  root :to => "my/dashboards#show", :locale => "en-US"

  resource :worldmap
  scope "/:locale", :constraints => { :locale => /(en-US|ja)/ } do
    devise_for :users
    devise_for :admins
    devise_scope :user do
      get "/logout" => "devise/sessions#destroy", :as => :logout
    end

    resources :posts
    resources :maps
    resources :users
    resources :bgeigie_imports, :only => [ :index, :show ]

    namespace :my do
      resource :dashboard
      resource :profile
      resources :bgeigie_imports do
        member do
          put :approve
        end
      end
      resources :maps
      resources :devices
      resources :measurements do
        collection do
          get :manifest
        end
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
        get "auth"
      end
    end
    resources :devices
    resources :measurements do
      collection do
        get :count
      end
    end
    resources :maps do
      resources :measurements do
        collection do
          post "add_to_map", :path => ":id/add"
        end
      end
    end

    resources :docs do 
      collection do
        match '/resources/:resource', :to => 'docs#show_resource'
      end
    end
  end

  authenticate :admin do
    namespace :admin do
      dobro_for :devices, :admins
      dobro_for :users, :controller => "admin/users"
    end
    match "/admin", to: "dobro/application#index"
  end
  
  match "/my/measurements/manifest", :to => "my/dashboards#show"
  match "reading", :to => "submissions#reading"
  match "device", :to => "submissions#device"
  match "details", :to => "submissions#details"
  match "manifest", :to => "submissions#manifest"

  match "/js_templates.js", :to => "js_templates#show"

  match "/"  => "api/application#options", :via => :options
  match "/" => "api/application#index", :via => :get

  #legacy fixes (maps.safecast.org now redirects to api.safecast.org, so people might be using the old maps.safecast.org/drive/add URI)
  match "/drive/add", :to => redirect("/")
end
