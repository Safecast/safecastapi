Safecast::Application.routes.draw do

  match "reading", :to => 'submissions#reading'

  root :to => 'submissions#sign_in'
end
