Rails.application.routes.draw do
  resources :users
  resources :books
  resources :authors do
    get "books", to: "books#index"

    # O # serve para chamar um método que está no controller do item antes da #
    get "books/:id", to: "books#teste"
end

  post "users/login", to: "users#login"
  resources :bookcases
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
