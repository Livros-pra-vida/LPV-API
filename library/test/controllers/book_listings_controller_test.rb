require "test_helper"

class BookListingsControllerTest < ActionDispatch::IntegrationTest
  test "lista é pública e mostra o nome do anunciante" do
    get book_listings_url, as: :json
    assert_response :success

    anuncios = response.parsed_body.index_by { |a| a["title"] }
    assert_equal "leitor_um", anuncios["Anúncio do Leitor Um"]["seller"]
    assert_equal users(:one).id, anuncios["Anúncio do Leitor Um"]["seller_id"]
    assert_equal "Anunciante Fictício", anuncios["Anúncio de Exemplo"]["seller"]
    assert_nil anuncios["Anúncio de Exemplo"]["seller_id"]
  end

  test "logado cria anúncio e o dono é o usuário do token" do
    assert_difference("BookListing.count", 1) do
      post book_listings_url,
           params: { book_listing: { title: "Novo", author_name: "Autor", modality: "Venda", price: 25.5, region: "Taguatinga", user_id: users(:two).id } },
           headers: auth_headers(users(:one)), as: :json
    end
    assert_response :created
    assert_equal users(:one).id, BookListing.find_by!(title: "Novo").user_id
  end

  test "venda exige preço e troca não aceita preço" do
    post book_listings_url, params: { book_listing: { title: "A", author_name: "B", modality: "Venda" } },
         headers: auth_headers(users(:one)), as: :json
    assert_response :unprocessable_content

    post book_listings_url, params: { book_listing: { title: "A", author_name: "B", modality: "Troca", price: 10 } },
         headers: auth_headers(users(:one)), as: :json
    assert_response :unprocessable_content
  end

  test "visitante não cria anúncio" do
    assert_no_difference("BookListing.count") do
      post book_listings_url, params: { book_listing: { title: "A", author_name: "B", modality: "Troca" } }, as: :json
    end
    assert_response :unauthorized
  end

  test "dono conclui a troca: status muda e a reputação sobe" do
    anuncio = book_listings(:do_leitor_um)
    patch book_listing_url(anuncio), params: { book_listing: { status: "Indisponivel" } },
          headers: auth_headers(users(:one)), as: :json
    assert_response :success
    assert_equal "Indisponivel", anuncio.reload.status
    assert_equal "5.0 (3 trocas)", anuncio.reputation
  end

  test "outro usuário não muda o status do anúncio, mas o admin muda" do
    anuncio = book_listings(:do_leitor_um)
    patch book_listing_url(anuncio), params: { book_listing: { status: "Em Negociacao" } },
          headers: auth_headers(users(:two)), as: :json
    assert_response :forbidden
    assert_equal "Disponivel", anuncio.reload.status

    patch book_listing_url(anuncio), params: { book_listing: { status: "Em Negociacao" } },
          headers: auth_headers(users(:admin)), as: :json
    assert_response :success
    assert_equal "Em Negociacao", anuncio.reload.status
  end

  test "status inválido volta 422" do
    patch book_listing_url(book_listings(:do_leitor_um)), params: { book_listing: { status: "Qualquer" } },
          headers: auth_headers(users(:one)), as: :json
    assert_response :unprocessable_content
  end

  test "só o admin exclui anúncios (inclusive os de exemplo)" do
    assert_no_difference("BookListing.count") do
      delete book_listing_url(book_listings(:do_leitor_um)), headers: auth_headers(users(:one)), as: :json
      assert_response :forbidden

      delete book_listing_url(book_listings(:do_leitor_um)), as: :json
      assert_response :unauthorized
    end

    assert_difference("BookListing.count", -2) do
      delete book_listing_url(book_listings(:do_leitor_um)), headers: auth_headers(users(:admin)), as: :json
      assert_response :no_content
      delete book_listing_url(book_listings(:de_exemplo)), headers: auth_headers(users(:admin)), as: :json
      assert_response :no_content
    end
  end
end
