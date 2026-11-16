class Book < ApplicationRecord
  belongs_to :bookcase
  belongs_to :author

  validates :title, presence: true
  validate :bookcase_within_limit, if: -> { new_record? || will_save_change_to_bookcase_id? }

  def author_name
    author&.name
  end

  def serializable_hash(options = nil)
    super({ methods: :author_name }.merge(options || {}))
  end

  private

  # Só confere o limite ao criar o livro ou ao movê-lo para outra estante.
  # (Antes a checagem rodava em todo update e usava um método que não existia.)
  def bookcase_within_limit
    return if bookcase.nil? || bookcase.limit.nil?

    if bookcase.books.count >= bookcase.limit
      errors.add(:base, "Estante já atingiu o limite de livros, aumente o limite (update) ou crie uma nova estante!!")
    end
  end
end
