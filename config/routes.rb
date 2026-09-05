Rails.application.routes.draw do
  resources :landmarks, only: [ :index, :edit, :update ]
  resources :tags, only: [ :index, :new, :create, :edit, :update, :destroy ]
  resources :invalid_urls, only: [ :index ]
  resources :url_checks, only: [ :create ]

  resource :quiz, only: [ :show, :create, :destroy ]
  namespace :quiz do
    resource :answer, only: :create
    resource :question, only: :show
    resource :result, only: :show
  end

  resource :map_quiz, only: [ :show, :create, :destroy ]
  namespace :map_quiz do
    resource :question, only: :show
    resource :answer, only: :create
    resource :result, only: :show
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "quizzes#show"
end
