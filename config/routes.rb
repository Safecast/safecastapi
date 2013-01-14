Safecast::Application.routes.draw do
  root :to => "my/dashboards#show", :locale => "en-US"

  resource :worldmap
  scope "(:locale)", :constraints => { :locale => /(en-US|ja)/ } do
    devise_for :users
    devise_for :admins
    devise_scope :user do
      get "/logout" => "devise/sessions#destroy", :as => :logout
    end

    resource :dashboard
    resource :profile

    resources :bgeigie_imports do
      member do
        put :approve
      end
    end
    resources :devices
    resources :measurements do
      collection do
        get :count
      end
    end
    resources :posts
    resources :users
    resources :bgeigie_imports
  end

  namespace :api do
    root :to => "application#index"

    resources :docs do 
      collection do
        match '/resources/:resource', :to => 'docs#show_resource'
      end
    end
  end

  #legacy fixes (maps.safecast.org now redirects to api.safecast.org, so people might be using the old maps.safecast.org/drive/add URI)
  match "/drive/add", :to => redirect("/")
  match '/count', :to => 'measurements#count'
end
