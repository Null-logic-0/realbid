Rails.application.routes.draw do
  root "products#index"

  resources :products

  resource :session, only: [ :new, :create, :destroy ]
  get "login", to: "sessions#new", as: "login"
  delete "logout", to: "sessions#destroy", as: "logout"

  # Signup / Users
  get "signup", to: "users#new", as: "signup"
  resources :users, only: [ :create, :show, :edit, :update ]

  # Current user profile
  get "profile", to: "users#profile", as: "profile"

  # Separate routes for updating profile and password
  patch "profile/update_profile", to: "users#update_profile", as: "update_profile"
  patch "profile/update_password", to: "users#update_password", as: "update_password"

  # Delete account
  delete "profile", to: "users#delete_account", as: "delete_account"
end
