class Book < ApplicationRecord
  belongs_to :estante, class_name: "Bookcase", foreign_key: "bookcase_id"
  belongs_to :author
  validate :is_the_bookcase_on_limit

  def is_the_bookcase_on_limit
    if self.bookcase.books.count >= self.bookcase.limit
      errors.add(:base, "Estante já atingiu o limite de livros, aumente o limite (update) ou crie uma nova estante!!")
    end
  end



end
