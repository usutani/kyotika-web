Rails.application.routes.draw do
  resources :landmarks, only: [ :index, :edit, :update ] do
    member do
      post :check_url
    end
  end
  resources :tags, only: [ :index, :new, :create, :edit, :update ]

  resource :quiz, only: [:show, :create, :destroy], controller: :quiz
  namespace :quiz do
    resource :answers, only: :create
    resource :question, only: :show
    resource :result, only: :show
  end

  get "invalid_urls", to: "landmarks#invalid_urls"

  get "up" => "rails/health#show", as: :rails_health_check

  root "landmarks#index"
end
