# Item do carrinho. O preço vem sempre do catálogo, nunca do navegador.
class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :catalog_book

  validates :quantity, numericality: { only_integer: true, in: 1..20, message: "deve ser de 1 a 20" }

  def subtotal
    catalog_book.price * quantity
  end

  def as_summary
    {
      id: id,
      catalog_book_id: catalog_book_id,
      title: catalog_book.title,
      author_name: catalog_book.author_name,
      image_url: catalog_book.image_url,
      unit_price: catalog_book.price.to_f,
      quantity: quantity,
      subtotal: subtotal.to_f
    }
  end
end
