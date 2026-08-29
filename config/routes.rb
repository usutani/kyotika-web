Rails.application.routes.draw do
  resources :landmarks, only: [ :index, :edit, :update ] do
    member do
      post :check_url
    end
  end
  resources :tags, only: [ :index, :new, :create, :edit, :update ]

  get  "quiz",        to: "quiz#start"
  post "quiz/start",  to: "quiz#create"
  get  "quiz/:id",    to: "quiz#show",    as: :quiz_question
  post "quiz/answer", to: "quiz#answer"
  get  "quiz/result", to: "quiz#result"
  delete "quiz",      to: "quiz#quit"

  get "invalid_urls", to: "landmarks#invalid_urls"

  get "up" => "rails/health#show", as: :rails_health_check

  root "landmarks#index"
end
