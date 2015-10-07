Safecast::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root :to => "dashboards#show"


  scope "(:locale)", :constraints => { :locale => /(en-US|ja)/ } do
    root :to => "dashboards#show"
    devise_for :users
    devise_for :admins
    devise_scope :user do
      get "/logout" => "devise/sessions#destroy", :as => :logout
    end

    resource :home, :controller => :home, :only => :show
    resource :dashboard
    resource :profile

    resources :bgeigie_imports do
      resources :bgeigie_logs, :only => :index
      member do
        put :submit
        put :approve
      end
    end

    resources :air_imports
    
    resources :devices do
      resources :measurements, :only => :index
    end
    resources :measurement_imports do
      resources :measurements, :only => :index
    end
    resources :measurements do
      collection do
        get :count
      end
    end
    resources :users do
      resources :measurements, :only => :index
    end
  end

  match '/api/*path' => redirect('/%{path}.%{format}'), :format => true
  match '/api/*path' => redirect('/%{path}'), :format => false
  post '/api/measurements' => 'measurements#create'
  post '/api/measurements.(:format)' => 'measurements#create'

  #legacy fixes (maps.safecast.org now redirects to api.safecast.org, so people might be using the old maps.safecast.org/drive/add URI)
  match "/drive/add", :to => redirect("/")
  match '/count', :to => 'measurements#count'
end
