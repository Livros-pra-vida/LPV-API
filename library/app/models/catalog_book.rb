class CatalogBook < ApplicationRecord
  has_many :ratings, dependent: :destroy

  validates :title, presence: true, uniqueness: { case_sensitive: false }
  validates :author_name, presence: true

  # Todos os livros com a quantidade e a média das notas, em uma única consulta
  # (evita uma consulta por livro). Livros sem nota ficam com contagem 0 e média nil.
  scope :with_rating_stats, -> {
    left_joins(:ratings)
      .group("catalog_books.id")
      .select("catalog_books.*, COUNT(ratings.id) AS stats_count, AVG(ratings.score) AS stats_average")
  }

  # Resumo público das avaliações de um livro. `my_score` é a nota do usuário logado (ou nil).
  # Aceita registros vindos de with_rating_stats (sem consulta extra) ou de uma busca comum.
  def as_summary(my_score: nil)
    count = has_attribute?(:stats_count) ? self[:stats_count].to_i : ratings.count
    average = has_attribute?(:stats_count) ? self[:stats_average] : ratings.average(:score)

    {
      id: id,
      title: title,
      author_name: author_name,
      ratings_count: count,
      average_rating: average&.to_f&.round(1),
      my_rating: my_score
    }
  end
end
