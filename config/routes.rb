Safecast::Application.routes.draw do

  match "reading", :to => 'submissions#reading'
  match "device", :to => 'submissions#device'
  match "details", :to => 'submissions#details'

  root :to => 'submissions#sign_in'
end
