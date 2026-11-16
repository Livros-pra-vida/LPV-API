require "test_helper"

class CatalogBooksControllerTest < ActionDispatch::IntegrationTest
  test "visitante (sem token) vê a lista com médias" do
    get catalog_books_url, as: :json
    assert_response :success

    livros = response.parsed_body.index_by { |l| l["id"] }
    um = livros[catalog_books(:one).id]
    dois = livros[catalog_books(:two).id]

    assert_equal 1, um["ratings_count"]
    assert_equal 4.0, um["average_rating"]
    assert_nil um["my_rating"]

    assert_equal 0, dois["ratings_count"]
    assert_nil dois["average_rating"]
  end

  test "resposta traz só o resumo: nada de notas individuais nem de usuários" do
    get catalog_books_url, as: :json

    chaves = response.parsed_body.first.keys.sort
    assert_equal %w[ author_name average_rating id my_rating ratings_count title ], chaves
  end

  test "com token, cada livro traz a nota do próprio usuário" do
    get catalog_books_url, headers: auth_headers(users(:two)), as: :json
    assert_response :success

    livros = response.parsed_body.index_by { |l| l["id"] }
    assert_equal 4, livros[catalog_books(:one).id]["my_rating"]
    assert_nil livros[catalog_books(:two).id]["my_rating"]
  end

  test "a nota de um usuário não aparece como my_rating de outro" do
    get catalog_books_url, headers: auth_headers(users(:one)), as: :json

    livros = response.parsed_body.index_by { |l| l["id"] }
    assert_nil livros[catalog_books(:one).id]["my_rating"]
    assert_equal 1, livros[catalog_books(:one).id]["ratings_count"]
  end

  test "token inválido é tratado como visitante (não dá erro)" do
    get catalog_books_url, headers: { "Authorization" => "Bearer token-falso" }, as: :json
    assert_response :success
    assert_nil response.parsed_body.first["my_rating"]
  end
end
