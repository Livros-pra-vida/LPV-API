# Conversa privada de negociação entre um comprador e o anunciante de um livro.
class Conversation < ApplicationRecord
  belongs_to :book_listing, optional: true # o anúncio pode ser apagado; a conversa continua
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  has_many :private_messages, -> { order(:created_at, :id) }, dependent: :destroy

  validates :listing_title, presence: true
  validate :comprador_diferente_do_anunciante

  # Todas as conversas em que o usuário participa (como comprador ou anunciante).
  scope :of_user, ->(user) { where(buyer_id: user.id).or(where(seller_id: user.id)) }

  def participant?(user)
    user && (buyer_id == user.id || seller_id == user.id)
  end

  def other_party(user)
    buyer_id == user.id ? seller : buyer
  end

  def summary_for(user)
    outra = other_party(user)
    ultima = private_messages.last
    {
      id: id,
      book_listing_id: book_listing_id,
      listing_title: listing_title,
      listing_image: book_listing&.image_url.to_s.start_with?("http") ? book_listing.image_url : nil,
      listing_status: book_listing&.status,
      role: buyer_id == user.id ? "comprador" : "anunciante",
      other_user: { id: outra.id, name: outra.username },
      last_message: ultima && { content: ultima.content.truncate(80), from_me: ultima.user_id == user.id, created_at: ultima.created_at },
      unread_count: private_messages.where(read_at: nil).where.not(user_id: user.id).count,
      last_message_at: last_message_at || created_at
    }
  end

  private

  def comprador_diferente_do_anunciante
    errors.add(:base, "Você não pode negociar com o seu próprio anúncio") if buyer_id.present? && buyer_id == seller_id
  end
end
