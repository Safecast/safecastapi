Safecast::Application.routes.draw do

  match "reading", :to => 'submissions#reading'
  match "device", :to => 'submissions#device'

  root :to => 'submissions#sign_in'
end
