require "test_helper"

class CatalogBookTest < ActiveSupport::TestCase
  test "título é obrigatório e único sem diferenciar maiúsculas" do
    assert_not CatalogBook.new(author_name: "X").valid?
    assert_not CatalogBook.new(title: "livro do catálogo um", author_name: "X").valid?
  end

  test "resumo com média arredondada em uma casa" do
    livro = catalog_books(:two)
    Rating.create!(user: users(:one), catalog_book: livro, score: 5)
    Rating.create!(user: users(:two), catalog_book: livro, score: 4)
    Rating.create!(user: users(:admin), catalog_book: livro, score: 4)

    resumo = livro.as_summary
    assert_equal 3, resumo[:ratings_count]
    assert_equal 4.3, resumo[:average_rating] # 13 / 3 = 4,33...
  end

  test "with_rating_stats traz contagem e média sem consulta por livro" do
    livros = CatalogBook.with_rating_stats.order(:id).to_a
    resumos = nil

    queries = 0
    contador = ->(*, payload) { queries += 1 unless payload[:name] == "SCHEMA" }
    ActiveSupport::Notifications.subscribed(contador, "sql.active_record") do
      resumos = livros.map(&:as_summary)
    end

    assert_equal 0, queries
    assert_equal [ 1, 0 ], resumos.map { |r| r[:ratings_count] }.sort.reverse
  end

  test "apagar o livro apaga as avaliações dele" do
    assert_difference("Rating.count", -1) { catalog_books(:one).destroy }
  end
end
