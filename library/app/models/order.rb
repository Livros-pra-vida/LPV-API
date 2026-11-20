# Pedido feito a partir do carrinho. Guarda uma cópia dos itens e preços do momento da compra.
class Order < ApplicationRecord
  SHIPPING = BigDecimal("10.00")
  STATUSES = [ "Em separação", "Enviado", "Entregue", "Cancelado" ].freeze

  belongs_to :user
  has_many :order_items, dependent: :destroy

  # Endereço de entrega gravado criptografado.
  encrypts :address

  validates :payment_method, inclusion: { in: User::PAGAMENTOS }
  validates :address, presence: true
  validates :status, inclusion: { in: STATUSES }

  # Cria o pedido com o carrinho do usuário (tudo ou nada) e esvazia o carrinho.
  def self.checkout!(user, payment_method)
    itens = user.cart_items.includes(:catalog_book).to_a
    return nil if itens.empty?

    transaction do
      subtotal = itens.sum(&:subtotal)
      pedido = user.orders.create!(
        payment_method: payment_method,
        address: user.endereco_formatado,
        subtotal: subtotal,
        shipping: SHIPPING,
        total: subtotal + SHIPPING
      )
      itens.each do |item|
        pedido.order_items.create!(
          catalog_book: item.catalog_book, title: item.catalog_book.title, image_url: item.catalog_book.image_url,
          unit_price: item.catalog_book.price, quantity: item.quantity
        )
      end
      user.cart_items.delete_all
      pedido
    end
  end

  def as_summary
    {
      id: id,
      status: status,
      payment_method: payment_method,
      address: address,
      subtotal: subtotal.to_f,
      shipping: shipping.to_f,
      total: total.to_f,
      created_at: created_at,
      items: order_items.map { |i| { title: i.title, image_url: i.image_url, unit_price: i.unit_price.to_f, quantity: i.quantity } }
    }
  end
end
