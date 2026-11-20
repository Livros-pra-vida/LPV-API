class Book < ApplicationRecord
  belongs_to :bookcase
  belongs_to :author

<<<<<<< HEAD
  validates :title, presence: true, length: { maximum: 200 }
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
=======
  validates :title, presence: true
>>>>>>> 821dca3581cf39540ec51ae425d239e22b7d4426
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
