class CatalogBook < ApplicationRecord
  has_many :ratings, dependent: :destroy

  # Admin que cadastrou o livro (nulo nos livros originais da loja).
  belongs_to :user, optional: true

  validates :title, presence: true, length: { maximum: 200 }, uniqueness: { case_sensitive: false }
  validates :author_name, presence: true, length: { maximum: 200 }
  validates :genre, presence: true, length: { maximum: 60 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than: 100_000 }
  validates :synopsis, length: { maximum: 2000 }
  validates :image_url, length: { maximum: 400_000 } # aceita imagem em data URL, mas não gigantes

  # Todos os livros com a quantidade e a média das notas, em uma única consulta
  # (evita uma consulta por livro). Livros sem nota ficam com contagem 0 e média nil.
  scope :with_rating_stats, -> {
    left_joins(:ratings)
      .group("catalog_books.id")
      .select("catalog_books.*, COUNT(ratings.id) AS stats_count, AVG(ratings.score) AS stats_average")
  }

  # Resumo público do livro com as avaliações. `my_score` é a nota do usuário logado (ou nil).
  # `include_publisher` (só para admin) acrescenta quem cadastrou o livro.
  # Aceita registros vindos de with_rating_stats (sem consulta extra) ou de uma busca comum.
  def as_summary(my_score: nil, include_publisher: false)
    count = has_attribute?(:stats_count) ? self[:stats_count].to_i : ratings.count
    average = has_attribute?(:stats_count) ? self[:stats_average] : ratings.average(:score)

    resumo = {
      id: id,
      title: title,
      author_name: author_name,
      genre: genre,
      price: price.to_f,
      image_url: image_url,
      synopsis: synopsis,
      ratings_count: count,
      average_rating: average&.to_f&.round(1),
      my_rating: my_score
    }
    resumo[:published_by] = user && { id: user.id, name: user.username } if include_publisher
    resumo
  end
end
