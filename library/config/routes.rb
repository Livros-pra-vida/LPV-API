Rails.application.routes.draw do
  post "users/login", to: "users#login"
  get "users/me", to: "users#me"
  
  resources :users
  resources :books, only: [:index, :create, :update, :destroy]
  resources :book_listings, only: [:index, :create, :update, :destroy]
  resources :news, only: [:index, :create, :update, :destroy]
  
  resources :authors do
    get "books", to: "books#index"
    get "books/:id", to: "books#teste"
  end

  resources :bookcases
  resources :messages, only: [:index, :create, :destroy]
  resources :favorites, only: [:index, :create, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end