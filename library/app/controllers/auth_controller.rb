# GET /auth/public_key   chave pública que o navegador usa para criptografar a senha.
# server_time ajuda o navegador a usar a hora do servidor (o relógio do PC pode estar errado).
class AuthController < ApplicationController
  def public_key
    render json: { key: SenhaCriptografada.chave_publica_base64, algorithm: "RSA-OAEP-256",
                   server_time: (Time.current.to_f * 1000).to_i }
  end
end
