Rails.application.routes.draw do
  resources :landmarks, only: [ :index, :edit, :update ] do
    member do
      post :check_url
    end
  end
  get "invalid_urls", to: "landmarks#invalid_urls"

  get "up" => "rails/health#show", as: :rails_health_check

  root "landmarks#index"
end
