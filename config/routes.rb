Safecast::Application.routes.draw do

  devise_for :users, :controllers => {
    :sessions => "users/sessions"
  }
  
  namespace :my do
    resource :dashboard
  end

  match "reading", :to => 'submissions#reading'
  match "device", :to => 'submissions#device'
  match "details", :to => 'submissions#details'

  root :to => 'my/dashboards#show'
end
