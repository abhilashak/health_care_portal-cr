Rails.application.routes.draw do
  # RESTful resources
  resources :hospitals
  resources :clinics
  resources :doctors
  resources :patients
  resources :appointments
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors like UptimeRobot or NewRelic
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Basic root route for our healthcare portal
  root "application#index"

  # Healthcare application routes will be added here as we build the features
  # namespace :api do
  #   resources :hospitals
  #   resources :clinics
  #   resources :doctors
  #   resources :patients
  #   resources :appointments
  # end
end
