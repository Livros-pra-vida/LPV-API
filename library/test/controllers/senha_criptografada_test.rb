require "test_helper"

# Senha criptografada no navegador com a chave pública da API (RSA-OAEP SHA-256).
class SenhaCriptografadaTest < ActionDispatch::IntegrationTest
  def trancar(senha, hora: Time.current, numero: SecureRandom.uuid)
    get "/auth/public_key", as: :json
    publica = OpenSSL::PKey.read(Base64.strict_decode64(response.parsed_body["key"]))
    pacote = { p: senha, t: (hora.to_f * 1000).to_i, n: numero }.to_json
    Base64.strict_encode64(publica.encrypt(pacote, SenhaCriptografada::OPCOES_RSA))
  end

  def cadastro_cifrado
    { username: "cifrado", email: "cifrado@example.com", cpf: "52998224725",
      password_encrypted: trancar("Senha@123"), password_confirmation_encrypted: trancar("Senha@123") }
  end

  test "cadastro e login com a senha criptografada" do
    post users_url, params: { user: cadastro_cifrado }, as: :json
    assert_response :created

    post users_login_url, params: { email: "cifrado@example.com", password_encrypted: trancar("Senha@123") }, as: :json
    assert_response :success

    post users_login_url, params: { email: "cifrado@example.com", password_encrypted: trancar("Errada@123") }, as: :json
    assert_response :unauthorized
  end

  test "pacote vencido é recusado" do
    post users_url, params: { user: cadastro_cifrado }, as: :json
    post users_login_url, params: { email: "cifrado@example.com", password_encrypted: trancar("Senha@123", hora: 1.hour.ago) }, as: :json
    assert_response :unprocessable_content
  end

  test "texto adulterado é recusado" do
    post users_login_url, params: { email: "x@example.com", password_encrypted: "isso-nao-e-um-pacote" }, as: :json
    assert_response :unprocessable_content
  end

  # Obs.: a proteção contra reaproveitar o mesmo pacote usa o cache do Rails, que nos testes
  # é desligado (null_store); por isso ela só age em desenvolvimento e produção.
end
