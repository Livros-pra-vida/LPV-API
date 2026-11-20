require "test_helper"

class CartsAndOrdersTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @headers = auth_headers(@user)
  end

  test "carrinho usa o preço do catálogo e soma itens repetidos" do
    post "/cart/items", params: { catalog_book_id: catalog_books(:one).id, price: 0.01 }, headers: @headers, as: :json
    post "/cart/items", params: { title: "livro do catálogo um" }, headers: @headers, as: :json
    assert_response :created

    corpo = response.parsed_body
    assert_equal 2, corpo["count"]
    assert_equal 60.0, corpo["subtotal"] # 2 x 30,00 (o price: 0.01 enviado foi ignorado)
    assert_equal 70.0, corpo["total"]    # + frete de 10,00

    item_id = corpo["items"].first["id"]
    patch "/cart/items/#{item_id}", params: { quantity: 3 }, headers: @headers, as: :json
    assert_equal 3, response.parsed_body["count"]

    delete "/cart/items/#{item_id}", headers: @headers, as: :json
    assert_equal 0, response.parsed_body["count"]
  end

  test "pedido exige endereço, usa o carrinho do banco e esvazia o carrinho" do
    post "/cart/items", params: { catalog_book_id: catalog_books(:two).id }, headers: @headers, as: :json

    post orders_url, params: { payment_method: "Pix" }, headers: @headers, as: :json
    assert_response :unprocessable_content # sem endereço

    @user.update!(cep: "70000000", rua: "Rua A", numero: "10", bairro: "Centro", cidade: "Brasília - DF")
    post orders_url, params: { payment_method: "Pix" }, headers: @headers, as: :json
    assert_response :created
    assert_equal 55.5, response.parsed_body["total"]
    assert_equal 0, @user.cart_items.count

    get orders_url, headers: @headers, as: :json
    assert_equal 1, response.parsed_body.size
  end

  test "favoritos e alertas ficam salvos no banco" do
    anuncio = book_listings(:do_leitor_um)
    post favorites_url, params: { book_listing_id: anuncio.id }, headers: @headers, as: :json
    assert_equal [ anuncio.id ], response.parsed_body

    delete favorite_url(anuncio.id), headers: @headers, as: :json
    assert_equal [], response.parsed_body

    post wish_alerts_url, params: { term: "Leitor Um" }, headers: @headers, as: :json
    assert_response :created
    assert_equal [ anuncio.id ], response.parsed_body["matches"].map { |m| m["id"] }
  end

  test "tudo exige login" do
    get "/cart", as: :json
    assert_response :unauthorized
    get orders_url, as: :json
    assert_response :unauthorized
    get conversations_url, as: :json
    assert_response :unauthorized
  end
end
