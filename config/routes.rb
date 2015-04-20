Rails.application.routes.draw do
  root 'homes#index'

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  resources :playlists, only: [:show, :index, :create, :destroy]
  resources :genres, only: [:show]
  resources :users, only: [:show]

  resource :session, only: [:new, :create, :destroy] do
    get "failure", on: :member
  end

  # namespace :admin do
  #   resources :users, only: [:index, :destroy]
  #   resources :playlists, only: [:destroy]
  # end
end
