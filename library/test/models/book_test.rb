require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "não aceita livro além do limite da estante" do
    bookcase = bookcases(:one) # limite 2, já tem 1
    assert Book.new(title: "Segundo", bookcase: bookcase, author: authors(:one)).valid?

    Book.create!(title: "Segundo", bookcase: bookcase, author: authors(:one))
    extra = Book.new(title: "Terceiro", bookcase: bookcase, author: authors(:one))
    assert_not extra.valid?
    assert_includes extra.errors.full_messages.join, "limite"
  end

  test "editar livro numa estante cheia continua permitido" do
    bookcases(:one).update!(limit: 1)
    book = books(:one)
    assert book.update(title: "Outro título")
  end

  test "precisa de título" do
    assert_not Book.new(bookcase: bookcases(:one), author: authors(:one)).valid?
  end
end
