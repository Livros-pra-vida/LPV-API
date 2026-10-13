class Author < ApplicationRecord
  has_many :books, class_name: "Book"
end
