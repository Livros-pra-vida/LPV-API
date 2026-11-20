require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # O front manda a senha pura (por HTTPS); a API confere as regras e faz SHA-256 + bcrypt.
  SENHA = "Senha@123"

  def dados_cadastro(extra = {})
    { username: "novo_leitor", email: "Novo@Example.com", password: SENHA,
      password_confirmation: SENHA, cpf: "52998224725", telefone: "61999998888" }.merge(extra)
  end

  test "cadastro cria o usuário e devolve token, sem o hash da senha" do
    assert_difference("User.count") do
      post users_url, params: { user: dados_cadastro }, as: :json
    end
    assert_response :created
    assert response.parsed_body["token"].present?
    assert_not response.parsed_body["user"].key?("password_digest")
  end

  test "cadastro nunca cria admin, mesmo se o cliente pedir" do
    post users_url, params: { user: dados_cadastro(admin: true) }, as: :json
    assert_response :created
    assert_not User.find(response.parsed_body["user"]["id"]).admin?
  end

  test "cadastro exige CPF com 11 números e e-mail único sem diferenciar maiúsculas" do
    post users_url, params: { user: dados_cadastro(cpf: "") }, as: :json
    assert_response :unprocessable_content

    post users_url, params: { user: dados_cadastro(email: "UM@example.com") }, as: :json
    assert_response :unprocessable_content
  end

  test "cadastro com campo desconhecido não derruba a API" do
    post users_url, params: { user: dados_cadastro(campo_que_nao_existe: "x") }, as: :json
    assert_response :created
  end

  test "login aceita o e-mail com maiúsculas e recusa senha errada" do
    post users_url, params: { user: dados_cadastro }, as: :json

    post users_login_url, params: { email: "NOVO@example.com", password: SENHA }, as: :json
    assert_response :success
    assert response.parsed_body["token"].present?

    post users_login_url, params: { email: "novo@example.com", password: "errada" }, as: :json
    assert_response :unauthorized
  end

  test "senha fraca é recusada pelo servidor" do
    %w[ curta1! semmaiuscula1! SemNumero! SemEspecial1 ].each do |fraca|
      post users_url, params: { user: dados_cadastro(password: fraca, password_confirmation: fraca) }, as: :json
      assert_response :unprocessable_content, "a senha #{fraca} deveria ser recusada"
    end
  end

  test "conta antiga (senha com SHA-256 feito no navegador) continua entrando" do
    antigo = User.new(username: "antigo", email: "antigo@example.com", cpf: "11144477735")
    antigo.password_digest = BCrypt::Password.create(Digest::SHA256.hexdigest("Velha@123"))
    antigo.save!(validate: false)

    post users_login_url, params: { email: "antigo@example.com", password: "Velha@123" }, as: :json
    assert_response :success
  end

  test "conta criada sem o SHA-256 (front novo + API antiga) também entra" do
    misto = User.new(username: "misto", email: "misto@example.com", cpf: "11144477735")
    misto.password_digest = BCrypt::Password.create("Mista@123")
    misto.save!(validate: false)

    post users_login_url, params: { email: "misto@example.com", password: "Mista@123" }, as: :json
    assert_response :success
  end

  test "trocar e-mail ou senha exige a senha atual" do
    post users_url, params: { user: dados_cadastro }, as: :json
    corpo = response.parsed_body
    headers = { "Authorization" => "Bearer #{corpo["token"]}" }
    id = corpo["user"]["id"]

    patch user_url(id), params: { user: { password: "Nova@1234" } }, headers: headers, as: :json
    assert_response :unprocessable_content

    patch user_url(id), params: { user: { password: "Nova@1234", current_password: SENHA } }, headers: headers, as: :json
    assert_response :success
    assert response.parsed_body["token"].present?

    post users_login_url, params: { email: "novo@example.com", password: "Nova@1234" }, as: :json
    assert_response :success
  end

  test "dados pessoais ficam criptografados no banco" do
    post users_url, params: { user: dados_cadastro(cep: "70000000", rua: "Rua das Flores") }, as: :json
    user = User.find(response.parsed_body["user"]["id"])
    bruto = User.connection.select_one("SELECT cpf, rua FROM users WHERE id = #{user.id}")

    assert_equal "52998224725", user.cpf
    assert_not_includes bruto["cpf"], "52998224725"
    assert_not_includes bruto["rua"], "Flores"
  end

  test "admin vê os dados de outra pessoa sem CPF e telefone" do
    get user_url(users(:one)), headers: auth_headers(users(:admin)), as: :json
    assert_response :success
    assert_not response.parsed_body.key?("cpf")
    assert_not response.parsed_body.key?("telefone")
  end

  test "lista de usuários é só para admin" do
    get users_url, as: :json
    assert_response :unauthorized

    get users_url, headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden

    get users_url, headers: auth_headers(users(:admin)), as: :json
    assert_response :success
  end

  test "usuário edita o próprio perfil, mas não o de outra pessoa" do
    patch user_url(users(:one)), params: { user: { telefone: "61988887777" } },
          headers: auth_headers(users(:one)), as: :json
    assert_response :success

    patch user_url(users(:two)), params: { user: { telefone: "61988887777" } },
          headers: auth_headers(users(:one)), as: :json
    assert_response :forbidden
  end

  test "perfil não aceita CPF inválido" do
    patch user_url(users(:one)), params: { user: { cpf: "123" } },
          headers: auth_headers(users(:one)), as: :json
    assert_response :unprocessable_content
  end

  test "usuário comum não consegue se promover a admin" do
    patch user_url(users(:one)), params: { user: { admin: true } },
          headers: auth_headers(users(:one)), as: :json
    assert_response :success
    assert_not users(:one).reload.admin?
  end

  test "usuário apaga a própria conta" do
    assert_difference("User.count", -1) do
      delete user_url(users(:two)), headers: auth_headers(users(:two)), as: :json
    end
    assert_response :no_content
  end
end
