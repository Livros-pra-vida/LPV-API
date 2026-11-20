require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  test "comprador abre conversa com o anunciante e as mensagens ficam criptografadas" do
    anuncio = book_listings(:do_leitor_um) # anunciante: users(:one)

    post conversations_url, params: { book_listing_id: anuncio.id, message: "Ainda está disponível?" },
                            headers: auth_headers(users(:two)), as: :json
    assert_response :created
    conversa_id = response.parsed_body["id"]

    post conversation_messages_url(conversa_id), params: { content: "Posso buscar amanhã" },
                                                 headers: auth_headers(users(:two)), as: :json
    assert_response :created

    bruto = PrivateMessage.connection.select_values("SELECT content FROM private_messages WHERE conversation_id = #{conversa_id}")
    assert_equal 2, bruto.size
    bruto.each { |texto| assert_not_includes texto, "disponível" }

    # O anunciante vê a conversa e as duas mensagens (descriptografadas).
    get conversation_url(conversa_id), headers: auth_headers(users(:one)), as: :json
    assert_response :success
    assert_equal [ "Ainda está disponível?", "Posso buscar amanhã" ], response.parsed_body["messages"].map { |m| m["content"] }
    assert_equal "anunciante", response.parsed_body["role"]
  end

  test "quem não participa não vê a conversa" do
    post conversations_url, params: { book_listing_id: book_listings(:do_leitor_um).id },
                            headers: auth_headers(users(:two)), as: :json
    conversa_id = response.parsed_body["id"]

    get conversation_url(conversa_id), headers: auth_headers(users(:admin)), as: :json
    assert_response :not_found

    post conversation_messages_url(conversa_id), params: { content: "intruso" },
                                                 headers: auth_headers(users(:admin)), as: :json
    assert_response :not_found
  end

  test "não dá para negociar com o próprio anúncio nem com anúncio de exemplo" do
    post conversations_url, params: { book_listing_id: book_listings(:do_leitor_um).id },
                            headers: auth_headers(users(:one)), as: :json
    assert_response :unprocessable_content

    post conversations_url, params: { book_listing_id: book_listings(:de_exemplo).id },
                            headers: auth_headers(users(:two)), as: :json
    assert_response :unprocessable_content
  end
end
