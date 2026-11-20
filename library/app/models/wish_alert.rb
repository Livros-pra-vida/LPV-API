# "Avise-me quando chegar": termo de busca de um livro que o usuário quer.
class WishAlert < ApplicationRecord
  belongs_to :user

  validates :term, presence: true, length: { minimum: 2, maximum: 120 },
                   uniqueness: { scope: :user_id, case_sensitive: false, message: "já está na sua lista de alertas" }

  # Anúncios disponíveis cujo título contém o termo.
  def matching_listings
    BookListing.where.not(status: "Indisponivel")
               .where("title ILIKE ?", "%#{BookListing.sanitize_sql_like(term)}%")
               .where.not(user_id: user_id)
  end

  def as_summary
    achados = matching_listings.order(created_at: :desc).limit(5)
    { id: id, term: term, created_at: created_at,
      matches: achados.map { |l| { id: l.id, title: l.title, modality: l.modality, seller: l.seller } } }
  end
end
