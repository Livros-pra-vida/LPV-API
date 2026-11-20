require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "aceita notas de 1 a 5" do
    (1..5).each do |nota|
      rating = Rating.new(user: users(:one), catalog_book: catalog_books(:two), score: nota)
      assert rating.valid?, "nota #{nota} deveria ser válida"
    end
  end

  test "recusa nota fora de 1..5, decimal ou texto" do
    [ 0, 6, 4.5, "abc", nil ].each do |ruim|
      rating = Rating.new(user: users(:one), catalog_book: catalog_books(:two), score: ruim)
      assert_not rating.valid?, "nota #{ruim.inspect} não deveria ser válida"
    end
  end

  test "um usuário só avalia cada livro uma vez" do
    repetida = Rating.new(user: users(:two), catalog_book: catalog_books(:one), score: 5)
    assert_not repetida.valid?
    assert_includes repetida.errors.full_messages.join, "já avaliou"
  end

  test "o banco também barra nota fora de 1..5" do
    rating = Rating.new(user: users(:one), catalog_book: catalog_books(:two), score: 9)
    assert_raises(ActiveRecord::StatementInvalid) { rating.save!(validate: false) }
  end
end
