class User < ApplicationRecord
  has_secure_password

  has_many :messages, dependent: :destroy

  # Token de sessão (login e chat). Expira em 12 horas.
  generates_token_for :api_session, expires_in: 12.hours

  validates :username, presence: true

  validates :email, presence: true, uniqueness: true

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  validates :cpf, length: { minimum: 11, maximum: 11 }, if: -> { password.present? }

  # Nunca devolve o hash da senha em nenhum JSON (index, show, login, update...)
  def serializable_hash(options = nil)
    options = (options || {}).dup
    options[:except] = Array(options[:except]) | [ :password_digest ]
    super(options)
  end
end
