Rails.application.routes.draw do
  resource :first_run, only: %i[show create]
  resource :session, only: %i[new create destroy]
  resource :profile, only: %i[show update]

  get "join/:join_code", to: "users#new", as: :join
  post "join/:join_code", to: "users#create"

  resource :account, only: %i[edit update] do
    scope module: "accounts" do
      resources :users, only: :update do
        scope module: "users" do
          resource :deactivation, only: %i[create destroy]
          resource :password, only: :update
        end
      end
      resource :join_code, only: :create
    end
  end

  resources :landmarks, except: :show
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
