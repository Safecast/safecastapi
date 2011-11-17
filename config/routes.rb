Safecast::Application.routes.draw do

  match "reading", :to => 'submissions#reading'
  match "device", :to => 'submissions#device'
  match "details", :to => 'submissions#details'
  match "manifest", :to => 'submissions#manifest'

  root :to => 'submissions#sign_in'
end
