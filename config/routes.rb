Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root 'application#index'

  # Redirect vendor script asset requests
  get 'fonts/:name' => redirect { |params, req| "assets/stylesheets/fonts/#{params[:name]}.#{params[:format]}" }

  # get 'signup' => 'user#new'
  # post 'create' => 'user#create'

  # get "login" => "sessions#login"
  # post "login" => "sessions#login_attempt"

  # Authentication
  get "signup" => "user#new"
  post "signup" => "user#create"
  get "login" => "sessions#login"
  post "login" => "sessions#login_attempt"
  get "logout" => "sessions#logout"
  get "home" => "sessions#home"
  get "profile" => "sessions#profile"
  post "profile" => "sessions#change_email"
  get "settings" => "sessions#settings"
  post "settings" => "sessions#change_password"

  # Organizations
  get "organizations/all" => "sessions#all_organizations", :as =>
    :all_organizations
  get "organizations/all/:page" =>
    "sessions#all_organizations_page", :as =>
    :all_organizations_pagina
  get "organizations" => "sessions#organizations"
  post "organizations" => "organizations#create"
  get "organization/:organization_name" => "organizations#index", :as =>
    :organization_page

  # Teams
  post "organization/:organization_name" => "teams#create"
  get "team/:organization_name/:team_name" => "teams#index", :as =>
    :team_page
  get "team/:organization_name/:team_name/search" =>
    "teams#search_events", :as => :team_events_search
  get "team/:organization_name/:team_name/:page" =>
    "teams#team_events_page", :as => :team_events_pagina, :constraints =>
    {:page => /[0-9]+/}
  post "team/:organization_name/:team_name/join" => "team_memberships#join"
  post "team/:organization_name/:team_name/leave" =>
    "team_memberships#leave"
  get "teams" => "team_memberships#teams"
  get "teams/:page" => "team_memberships#teams_page", :as => :teams_pagina

  # Users
  get "profile/:name" => "user#profile", :name => /\w*/, :as =>
    :user_profile_page

  # Events
  post "team/:organization_name/:team_name/event/new" =>
    "events#new", :as => :new_event
  get "event/:organization_name/:team_name/:event_id" =>
    "events#index", :as => :event_page
  get "unsubmitted" => "events#unsubmitted", :as => :unsubmitted_events

  # Metrics
  get "metrics/:organization_name/:team_name/:event_id" =>
    "metrics#index", :as => :metrics
  post "metrics/:organization_name/:team_name/:event_id/new" =>
    "metrics#new", :as => :metrics_submission
end
