class User < ApplicationRecord
  has_secure_password

  has_many :messages, dependent: :destroy

  # Estantes são privadas: cada uma pertence a um único usuário.
  has_many :bookcases, dependent: :destroy
  has_many :books, through: :bookcases

  # Avaliações públicas do catálogo (uma por livro).
  has_many :ratings, dependent: :destroy

  # Anúncios do Comprar & Trocar somem junto com a conta; livros do catálogo cadastrados
  # por um admin continuam existindo (o campo user_id fica nulo).
  has_many :book_listings, dependent: :destroy
  has_many :catalog_books, dependent: :nullify

  # Carrinho, pedidos, favoritos e alertas de livro desejado (antes ficavam só no navegador).
  has_many :cart_items, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :wish_alerts, dependent: :destroy

  # Conversas privadas de negociação (como comprador ou como anunciante).
  has_many :conversations_as_buyer, class_name: "Conversation", foreign_key: :buyer_id, dependent: :destroy
  has_many :conversations_as_seller, class_name: "Conversation", foreign_key: :seller_id, dependent: :destroy
  has_many :private_messages, dependent: :destroy

  # Notícias publicadas (ficam no site mesmo se o admin sair) e ações de moderação registradas.
  has_many :news_posts, dependent: :nullify
  has_many :admin_actions, foreign_key: :admin_id, dependent: :nullify

  # Dados pessoais gravados CRIPTOGRAFADOS no banco (AES-256-GCM, Active Record Encryption).
  # Quem abrir a tabela no PostgreSQL vê só um texto embaralhado; a API descriptografa sozinha.
  encrypts :cpf, :telefone, :cep, :rua, :numero, :bairro, :cidade

  PAGAMENTOS = [ "Pix", "Cartão de Crédito", "Cartão de Débito", "Boleto" ].freeze

  # Regras da senha (as mesmas mostradas na tela de cadastro).
  REGRAS_SENHA = {
    "ter pelo menos 8 caracteres" => ->(s) { s.length >= 8 },
    "ter 1 letra maiúscula" => ->(s) { s.match?(/[A-Z]/) },
    "ter 1 número" => ->(s) { s.match?(/[0-9]/) },
    "ter 1 caractere especial (ex.: ! @ # $)" => ->(s) { s.match?(/[^A-Za-z0-9\s]/) }
  }.freeze

  # Token de sessão (login e chat). Expira em 12 horas.
  # Incluir o password_digest faz o token antigo deixar de valer quando a senha muda.
  generates_token_for :api_session, expires_in: 12.hours do
    password_digest&.last(10)
  end

  validates :username, presence: true, length: { maximum: 50 }

  # E-mail obrigatório, com formato válido e único sem diferenciar maiúsculas.
  validates :email, presence: true, length: { maximum: 120 },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "não é válido" },
                    uniqueness: { case_sensitive: false }

  validate :senha_forte

  # CPF: obrigatório no cadastro e sempre com 11 números.
  validates :cpf, presence: true, on: :create
  validates :cpf, format: { with: /\A\d{11}\z/, message: "deve ter exatamente 11 números" }, allow_blank: true
  validates :telefone, format: { with: /\A\d{10,11}\z/, message: "deve ter 10 ou 11 números (com DDD)" }, allow_blank: true

  validates :cep, format: { with: /\A\d{8}\z/, message: "deve ter 8 números" }, allow_blank: true
  validates :rua, :bairro, :cidade, length: { maximum: 120 }
  validates :numero, length: { maximum: 10 }
  validates :pagamento_favorito, inclusion: { in: PAGAMENTOS }, allow_blank: true
  # Foto de perfil: link https ou imagem em data URL, até ~300 KB.
  validates :avatar_url, length: { maximum: 400_000 },
                         format: { with: %r{\A(https://|data:image/(png|jpe?g|webp|gif);base64,)}, message: "precisa ser uma imagem" },
                         allow_blank: true

  # A senha chega pura (por HTTPS) e é transformada em SHA-256 antes do bcrypt.
  # Isso mantém funcionando as contas antigas, criadas quando o navegador fazia o SHA-256,
  # e permite que o SERVIDOR confira as regras da senha (antes não dava para conferir).
  def password=(senha)
    @senha_digitada = senha.to_s if senha.present?
    super(senha.present? ? self.class.pre_hash(senha) : senha)
  end

  def password_confirmation=(senha)
    super(senha.present? ? self.class.pre_hash(senha) : senha)
  end

  # Confere a senha digitada. Aceita os dois formatos que existem no banco:
  # 1) o normal: bcrypt(SHA-256(senha)) — contas antigas e as criadas pela API nova;
  # 2) bcrypt(senha) — contas criadas no período em que o front novo falava com a API antiga.
  def authenticate(senha)
    return false if senha.blank?

    super(self.class.pre_hash(senha)) || super(senha.to_s)
  end

  def self.pre_hash(senha)
    Digest::SHA256.hexdigest(senha.to_s)
  end

  # Conta suspensa por um administrador: não entra, não escreve no chat nem anuncia.
  def suspended?
    suspended_at.present?
  end

  def endereco_completo?
    [ cep, rua, bairro, cidade ].all?(&:present?)
  end

  def endereco_formatado
    return "" unless endereco_completo?

    "#{rua}, nº #{numero.presence || 'S/N'} - #{bairro}, #{cidade} (CEP: #{cep})"
  end

  # Dados que o próprio dono vê (perfil completo).
  def as_owner_json
    as_json(except: [ :password_digest ])
  end

  # Dados que um admin vê de OUTRA pessoa: sem CPF, telefone, nascimento nem endereço completo (LGPD).
  def as_public_json
    as_json(only: [ :id, :username, :email, :admin, :created_at, :avatar_url, :suspended_at, :suspended_reason ])
      .merge("cidade" => cidade)
  end

  # Nunca devolve o hash da senha em nenhum JSON (index, show, login, update...)
  def serializable_hash(options = nil)
    options = (options || {}).dup
    options[:except] = Array(options[:except]) | [ :password_digest ]
    super(options)
  end

  private

  def senha_forte
    return if @senha_digitada.nil?

    faltando = REGRAS_SENHA.reject { |_, regra| regra.call(@senha_digitada) }.keys
    errors.add(:password, "precisa #{faltando.to_sentence(last_word_connector: ' e ')}") if faltando.any?
  end
end
