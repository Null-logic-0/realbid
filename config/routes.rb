Rails.application.routes.draw do
  root "products#index"

  # Webhooks
  get "webhooks/create"

  post "/webhooks", to: "webhooks#create"

  # Payments
  post "/create-checkout-session", to: "payments#create"
  get "/payments/success", to: "payments#success", as: "success_payments"
  get "/payments/cancel", to: "payments#cancel", as: "cancel_payments"
  get "payments/create"
  get "payments/success"
  get "payments/cancel"

  # Products and bids
  resources :products do
    resources :bids, only: [ :create ]
    collection do
      get :search
      get :my_auctions
    end
  end

  # Notifications
  resources :notifications do
    post :mark_as_read, on: :member
  end

  # Sessions
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
