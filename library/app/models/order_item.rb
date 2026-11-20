class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :catalog_book, optional: true # o livro pode sair do catálogo; o pedido continua

  validates :title, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
