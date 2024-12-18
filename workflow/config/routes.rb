Rails.application.routes.draw do
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "workspace" => "board#index", as: :workspace
  resources :board, :param => :key
  post "board/:key/rename" => "board#rename", as: :board_rename
  post "board/:key/swimlane/move" => "swimlane#move", as: :swimlane_position
  post "board/:key/item/move" => "item#move", as: :item_position
  post "board/:key/item/:id/rename" => "item#rename", as: :item_rename
  post "board/:key/swimlane/:lane/item" => "item#create", as: :item_creation

  # get "board" => "board#index"
  # post "board" => "board#create"
  # get "board/:key" => "board#show"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
