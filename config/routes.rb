ActionController::Routing::Routes.draw do |map|
  map.resources :users, :member => { :enable => :put } do |users|
    users.resources :roles
  end

  map.resource  :session
  map.resources :lost_passwords
  
  # home
  # map.root :controller => "home"

  # common url idioms for auth
  map.signin   '/login',  :controller => 'sessions', :action => 'new'
  map.signout  '/logout', :controller => 'sessions', :action => 'destroy'

  # common url idioms for registration
  map.signup   '/signup',                :controller => 'users', :action => 'new'
  map.activate '/activate/:id',          :controller => 'users', :action => 'activate'
  map.resend   '/resend_activation/:id', :controller => 'users', :action => 'resend_activation'

  map.update_lost_password  '/passwords/update', :controller => 'lost_passwords', :action => 'update'
  map.edit_lost_password    '/passwords/edit', :controller => 'lost_passwords', :action => 'edit'


  # catchall for 404s
  # map.connect "*anything", :controller => "static", :action => "page_not_found"
end
