Rails.application.routes.draw do
  resources :landmarks, only: [ :index ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "landmarks#index"
end
