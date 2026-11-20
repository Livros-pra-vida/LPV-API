require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @one = users(:one)
    @two = users(:two)
    @livro = catalog_books(:one) # já tem a nota 4 do usuário "two"
  end

  def avaliar(livro, score, user: @one, **extra)
    put catalog_book_rating_url(livro),
        params: { rating: { score: score }.merge(extra) },
        headers: auth_headers(user), as: :json
  end

  test "exige login para avaliar e para remover" do
    put catalog_book_rating_url(@livro), params: { rating: { score: 5 } }, as: :json
    assert_response :unauthorized

    delete catalog_book_rating_url(@livro), as: :json
    assert_response :unauthorized
  end

  test "cria a avaliação e devolve o resumo atualizado" do
    assert_difference("Rating.count", 1) do
      avaliar(@livro, 5)
    end

    assert_response :success
    body = response.parsed_body
    assert_equal 2, body["ratings_count"]
    assert_equal 4.5, body["average_rating"]
    assert_equal 5, body["my_rating"]
  end

  test "avaliar de novo troca a nota e não cria outra linha" do
    assert_no_difference("Rating.count") do
      avaliar(@livro, 2, user: @two)
    end

    assert_response :success
    body = response.parsed_body
    assert_equal 1, body["ratings_count"]
    assert_equal 2.0, body["average_rating"]
    assert_equal 2, body["my_rating"]
  end

  test "mudar a própria nota não mexe na nota de outra pessoa" do
    avaliar(@livro, 1, user: @one)
    assert_equal 4, ratings(:dois_no_um).reload.score
  end

  test "o dono da avaliação é o usuário do token, mesmo que mandem user_id" do
    avaliar(@livro, 5, user: @one, user_id: @two.id)

    assert_equal 4, ratings(:dois_no_um).reload.score
    assert_equal 5, Rating.find_by!(user: @one, catalog_book: @livro).score
  end

  test "notas inválidas devolvem 422 e não gravam nada" do
    [ 0, 6, -1, 4.5, "abc", nil ].each do |ruim|
      assert_no_difference("Rating.count") do
        avaliar(@livro, ruim)
      end
      assert_response :unprocessable_content, "nota #{ruim.inspect} deveria ser recusada"
    end
  end

  test "livro que não existe no catálogo devolve 404" do
    assert_no_difference("Rating.count") do
      avaliar(0, 5)
    end
    assert_response :not_found
  end

  test "destroy remove só a avaliação de quem pediu" do
    assert_difference("Rating.count", -1) do
      delete catalog_book_rating_url(@livro), headers: auth_headers(@two), as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert_equal 0, body["ratings_count"]
    assert_nil body["average_rating"]
    assert_nil body["my_rating"]
  end

  test "destroy de quem não avaliou não apaga a nota dos outros" do
    assert_no_difference("Rating.count") do
      delete catalog_book_rating_url(@livro), headers: auth_headers(@one), as: :json
    end

    assert_response :success
    assert_equal 1, response.parsed_body["ratings_count"]
  end
end
