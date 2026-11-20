Rails.application.routes.draw do
  post "users/login", to: "users#login"
  get "auth/public_key", to: "auth#public_key" # chave para criptografar a senha no navegador
  get "users/me", to: "users#me"

  resources :users
  resources :books, only: [ :index, :show, :create, :update, :destroy ]
  resources :book_listings, only: [ :index, :create, :update, :destroy ]

  # Catálogo da loja: lista pública com médias; avaliar exige login (1 nota por usuário e livro).
  # Adicionar e excluir livros do catálogo é só para admin.
  resources :catalog_books, only: [ :index, :create, :destroy ] do
    resource :rating, only: [ :update, :destroy ], controller: "ratings"
  end

  resources :authors do
    get "books", to: "books#index"
  end

  resources :bookcases
  resources :messages, only: [ :index, :create, :destroy ]

  # Chat privado de negociação (mensagens criptografadas no banco)
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ], controller: "private_messages"
  end

  # Carrinho salvo no banco
  get "cart", to: "carts#show"
  post "cart/items", to: "carts#add"
  patch "cart/items/:id", to: "carts#update_item"
  delete "cart/items/:id", to: "carts#remove_item"

  resources :orders, only: [ :index, :create ]
  resources :favorites, only: [ :index, :create, :destroy ] # :id = id do anúncio
  resources :wish_alerts, only: [ :index, :create, :destroy ]

  get "up" => "rails/health#show", as: :rails_health_check
end
