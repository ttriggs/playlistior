Rails.application.routes.draw do
  root 'homes#index'

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  # get "/auth/spotify/callback", to: "sessions#create"

  resource :session, only: [:new, :create, :destroy] do
    get "failure", on: :member
  end

end
