# Anúncio do Comprar & Trocar marcado como favorito.
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :book_listing

  validates :book_listing_id, uniqueness: { scope: :user_id }
end
