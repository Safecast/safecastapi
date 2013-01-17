Safecast::Application.routes.draw do
  root :to => "home#show", :locale => "en-US"

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
      resources :bgeigie_logs, :only => :index
      member do
        put :submit
        put :approve
      end
    end
    resources :devices
    resources :measurements do
      collection do
        get :count
      end
    end
    resources :users
  end

  match '/api/*path' => redirect('/%{path}.%{format}'), :format => true
  match '/api/*path' => redirect('/%{path}'), :format => false

  #legacy fixes (maps.safecast.org now redirects to api.safecast.org, so people might be using the old maps.safecast.org/drive/add URI)
  match "/drive/add", :to => redirect("/")
  match '/count', :to => 'measurements#count'
end
