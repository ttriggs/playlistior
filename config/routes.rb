Rails.application.routes.draw do
  root 'homes#index'

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  get "/about", to: "homes#show"

  resources :playlists, only: [:show, :index, :create, :destroy]
  resources :genres, only: [:show]
  resources :follows, only: [:create, :destroy]
  resources :users, only: [:show]

  namespace :api do
    namespace :v1 do
      resources :playlists, only: [:show]
    end
  end

  resource :session, only: [:new, :create, :destroy] do
    get "failure", on: :member
  end
end
