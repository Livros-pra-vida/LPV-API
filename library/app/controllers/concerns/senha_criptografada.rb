# Senha criptografada no navegador (camada extra além do HTTPS).
#
# Como funciona:
#  1. O front pede a chave PÚBLICA em GET /auth/public_key.
#  2. O navegador tranca { p: senha, t: hora, n: número único } com RSA-OAEP (SHA-256).
#  3. Só a API, que tem a chave PRIVADA, consegue destrancar. No DevTools aparece só texto embaralhado.
#  4. Cada pacote vale por 10 minutos e uma única vez (quem copiar o texto não consegue reaproveitar).
#
# Os campos chegam como "password_encrypted", "password_confirmation_encrypted" e
# "current_password_encrypted" e são trocados pelos campos normais antes de chegar no controller.
module SenhaCriptografada
  extend ActiveSupport::Concern

  CAMPOS = %w[ password password_confirmation current_password ].freeze
  VALIDADE = 10.minutes
  OPCOES_RSA = { "rsa_padding_mode" => "oaep", "rsa_oaep_md" => "sha256", "rsa_mgf1_md" => "sha256" }.freeze

  class PacoteInvalido < StandardError; end

  included do
    before_action :abrir_senhas_criptografadas
    rescue_from PacoteInvalido do
      render json: { error: "Não foi possível ler a senha enviada. Recarregue a página e tente de novo.",
                     errors: [ "Não foi possível ler a senha enviada. Recarregue a página e tente de novo." ] },
             status: :unprocessable_content
    end
  end

  # Par de chaves RSA da API. Fica guardado no cache do Rails (banco), então sobrevive a reinícios
  # e é o mesmo para todas as instâncias. Se o cache for apagado, um par novo é criado sozinho.
  def self.chave
    @chave ||= OpenSSL::PKey::RSA.new(
      Rails.cache.fetch("lpv:chave_rsa_login") { OpenSSL::PKey::RSA.new(2048).private_to_pem }
    )
  end

  def self.chave_publica_base64
    Base64.strict_encode64(chave.public_to_der)
  end

  # Destranca um pacote e devolve a senha. Recusa pacote vencido, repetido ou adulterado.
  def self.abrir(texto)
    bruto = chave.decrypt(Base64.strict_decode64(texto.to_s), OPCOES_RSA)
    dados = JSON.parse(bruto.force_encoding("UTF-8"))

    idade = (Time.current.to_f * 1000 - dados["t"].to_f).abs
    raise PacoteInvalido, "vencido" if idade > VALIDADE.in_milliseconds
    raise PacoteInvalido, "sem número único" if dados["n"].blank?
    unless Rails.cache.write("lpv:pacote_usado:#{dados['n']}", true, unless_exist: true, expires_in: VALIDADE * 2)
      raise PacoteInvalido, "repetido"
    end

    dados["p"].to_s
  rescue OpenSSL::PKey::PKeyError, ArgumentError, JSON::ParserError
    raise PacoteInvalido, "ilegível"
  end

  private

  def abrir_senhas_criptografadas
    [ params, params[:user] ].each do |grupo|
      next unless grupo.respond_to?(:key?)

      CAMPOS.each do |campo|
        cifrado = grupo.delete("#{campo}_encrypted")
        grupo[campo] = SenhaCriptografada.abrir(cifrado) if cifrado.present?
      end
    end
  end
end
