require "test_helper"

# Ações de moderação do administrador: ver/excluir perfis e apagar mensagens do chat.
class AdminModerationTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  test "admin vê o perfil de qualquer usuário; usuário comum só vê o próprio" do
    get user_url(users(:one)), headers: auth_headers(users(:admin)), as: :json
    assert_response :success
    assert_equal "leitor_um", response.parsed_body["username"]
    assert_not response.parsed_body.key?("password_digest")

    get user_url(users(:two)), headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden
  end

  test "admin exclui um usuário comum e tudo que é dele" do
    ana = users(:one)
    assert ana.messages.exists? && ana.book_listings.exists?

    assert_difference("User.count", -1) do
      delete user_url(ana), headers: auth_headers(users(:admin)), as: :json
    end
    assert_response :no_content
    assert_not Message.exists?(user_id: ana.id)
    assert_not BookListing.exists?(user_id: ana.id)
  end

  test "excluir quem cadastrou livros do catálogo mantém o livro" do
    assert_no_difference("CatalogBook.count") do
      delete user_url(users(:admin)), headers: auth_headers(users(:admin)), as: :json
    end
    assert_nil catalog_books(:two).reload.user_id
  end

  test "admin não exclui outro admin" do
    outro = User.create!(username: "outro_admin", email: "outro@example.com", password: "Senha-Longa-123",
                         cpf: "44444444444", admin: true)
    assert_no_difference("User.count") do
      delete user_url(outro), headers: auth_headers(users(:admin)), as: :json
    end
    assert_response :forbidden
  end

  test "usuário comum não exclui outro usuário" do
    assert_no_difference("User.count") do
      delete user_url(users(:two)), headers: auth_headers(users(:one)), as: :json
    end
    assert_response :forbidden
  end

  test "mensagens trazem o user_id de quem escreveu" do
    get messages_url, headers: auth_headers(users(:one)), as: :json
    assert_response :success
    msg = response.parsed_body.find { |m| m["content"] == "Olá do leitor dois" }
    assert_equal users(:two).id, msg["user_id"]
  end

  test "admin apaga a mensagem de qualquer pessoa" do
    assert_difference("Message.count", -1) do
      delete message_url(messages(:do_leitor_um)), headers: auth_headers(users(:admin)), as: :json
    end
    assert_response :no_content
  end

  test "apagar a mensagem avisa os chats abertos" do
    msg = messages(:do_leitor_um)
    avisos = capture_broadcasts("chat_global") do
      delete message_url(msg), headers: auth_headers(users(:admin)), as: :json
    end
    assert_includes avisos, { "id" => msg.id, "deleted" => true }
  end

  test "usuário comum e visitante não apagam mensagens" do
    assert_no_difference("Message.count") do
      delete message_url(messages(:do_leitor_dois)), headers: auth_headers(users(:one)), as: :json
      assert_response :forbidden

      delete message_url(messages(:do_leitor_dois)), as: :json
      assert_response :unauthorized
    end
  end
end
