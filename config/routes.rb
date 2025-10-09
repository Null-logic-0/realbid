Rails.application.routes.draw do
  # root "posts#index"

  resource :session, only: [ :new, :create, :destroy ]
  get "login", to: "sessions#new", as: "login"
  resources :users
  get "signup" => "users#new"
end
