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
    assert_equal %w[ author_name average_rating genre id image_url my_rating price ratings_count synopsis title ], chaves
  end

  test "só o admin vê quem cadastrou o livro" do
    get catalog_books_url, as: :json
    assert_not response.parsed_body.any? { |l| l.key?("published_by") }

    get catalog_books_url, headers: auth_headers(users(:one)), as: :json
    assert_not response.parsed_body.any? { |l| l.key?("published_by") }

    get catalog_books_url, headers: auth_headers(users(:admin)), as: :json
    livros = response.parsed_body.index_by { |l| l["id"] }
    assert_equal({ "id" => users(:admin).id, "name" => "administrador" }, livros[catalog_books(:two).id]["published_by"])
    assert_nil livros[catalog_books(:one).id]["published_by"]
  end

  test "admin cadastra um livro e ele fica com o admin do token como dono" do
    assert_difference("CatalogBook.count", 1) do
      post catalog_books_url,
           params: { catalog_book: { title: "Livro Novo", author_name: "Alguém", genre: "Fantasia", price: 19.9, user_id: users(:one).id } },
           headers: auth_headers(users(:admin)), as: :json
    end
    assert_response :created
    assert_equal users(:admin).id, CatalogBook.find_by!(title: "Livro Novo").user_id
  end

  test "cadastro de livro inválido ou repetido volta 422" do
    post catalog_books_url, params: { catalog_book: { title: "Sem gênero", author_name: "X" } },
         headers: auth_headers(users(:admin)), as: :json
    assert_response :unprocessable_content

    post catalog_books_url, params: { catalog_book: { title: "livro do catálogo um", author_name: "X", genre: "Drama", price: 10 } },
         headers: auth_headers(users(:admin)), as: :json
    assert_response :unprocessable_content
  end

  test "usuário comum e visitante não cadastram nem excluem livros" do
    assert_no_difference("CatalogBook.count") do
      post catalog_books_url, params: { catalog_book: { title: "X", author_name: "Y", genre: "Z", price: 1 } },
           headers: auth_headers(users(:one)), as: :json
      assert_response :forbidden

      post catalog_books_url, params: { catalog_book: { title: "X", author_name: "Y", genre: "Z", price: 1 } }, as: :json
      assert_response :unauthorized

      delete catalog_book_url(catalog_books(:one)), headers: auth_headers(users(:one)), as: :json
      assert_response :forbidden

      delete catalog_book_url(catalog_books(:one)), as: :json
      assert_response :unauthorized
    end
  end

  test "admin exclui o livro e as avaliações dele" do
    assert_difference([ "CatalogBook.count", "Rating.count" ], -1) do
      delete catalog_book_url(catalog_books(:one)), headers: auth_headers(users(:admin)), as: :json
    end
    assert_response :no_content
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
