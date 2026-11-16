class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :catalog_book

  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5,
                                    message: "deve ser um número inteiro de 1 a 5" }
  validates :user_id, uniqueness: { scope: :catalog_book_id, message: "já avaliou este livro" }
end
