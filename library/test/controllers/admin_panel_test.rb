require "test_helper"

# Moderação: novidades só do admin, painel, suspensão de contas e registro das ações.
class AdminPanelTest < ActionDispatch::IntegrationTest
  NOTICIA = { title: "Nova edição de Duna", kind: "noticia", category: "livros",
              summary: "Capa dura", source_url: "https://exemplo.com/duna" }.freeze

  test "todos leem as novidades, mas só o admin publica, edita e apaga" do
    get news_posts_url, as: :json
    assert_response :success

    post news_posts_url, params: { news_post: NOTICIA }, headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden

    post news_posts_url, params: { news_post: NOTICIA }, headers: auth_headers(users(:admin)), as: :json
    assert_response :created
    id = response.parsed_body["id"]

    patch news_post_url(id), params: { news_post: { title: "Duna: edição de luxo" } }, headers: auth_headers(users(:admin)), as: :json
    assert_equal "Duna: edição de luxo", response.parsed_body["title"]

    delete news_post_url(id), headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden
    delete news_post_url(id), headers: auth_headers(users(:admin)), as: :json
    assert_response :no_content

    assert_equal [ "publicou a novidade", "editou a novidade", "apagou a novidade" ],
                 AdminAction.order(:id).pluck(:action)
  end

  test "lançamento exige data" do
    post news_posts_url, params: { news_post: NOTICIA.merge(kind: "lancamento") }, headers: auth_headers(users(:admin)), as: :json
    assert_response :unprocessable_content
  end

  test "conta suspensa não usa o site até ser reativada" do
    post admin_suspend_user_url(users(:one)), params: { reason: "Spam no chat" }, headers: auth_headers(users(:admin)), as: :json
    assert_response :success

    get "/cart", headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden
    assert_includes response.parsed_body["error"], "Spam no chat"

    post admin_reactivate_user_url(users(:one)), headers: auth_headers(users(:admin)), as: :json
    get "/cart", headers: auth_headers(users(:one)), as: :json
    assert_response :success
  end

  test "suspender exige motivo e não vale para outro admin" do
    post admin_suspend_user_url(users(:one)), params: { reason: "" }, headers: auth_headers(users(:admin)), as: :json
    assert_response :unprocessable_content

    outro = User.create!(username: "outro", email: "outro2@example.com", password: "Senha@123", cpf: "11144477735", admin: true)
    post admin_suspend_user_url(outro), params: { reason: "x" }, headers: auth_headers(users(:admin)), as: :json
    assert_response :unprocessable_content
  end

  test "painel é só para admin" do
    get admin_dashboard_url, headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden

    get admin_dashboard_url, headers: auth_headers(users(:admin)), as: :json
    assert_response :success
    assert response.parsed_body.key?("usuarios")
  end

  test "admin promove usuário, mas não rebaixa outro admin" do
    patch admin_set_admin_user_url(users(:one)), params: { admin: true }, headers: auth_headers(users(:admin)), as: :json
    assert users(:one).reload.admin?

    patch admin_set_admin_user_url(users(:one)), params: { admin: false }, headers: auth_headers(users(:admin)), as: :json
    assert_response :unprocessable_content
  end

  test "admin muda o status de um pedido e fica registrado" do
    pedido = users(:two).orders.create!(payment_method: "Pix", address: "Rua A", subtotal: 10, shipping: 10, total: 20)
    patch admin_update_order_url(pedido), params: { status: "Enviado" }, headers: auth_headers(users(:admin)), as: :json
    assert_response :success
    assert_equal "Enviado", pedido.reload.status
    assert_equal "Em separação → Enviado", AdminAction.last.details

    get admin_actions_url, headers: auth_headers(users(:admin)), as: :json
    assert_equal "mudou o status do pedido", response.parsed_body.first["action"]
  end
end
