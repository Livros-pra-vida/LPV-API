class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true

  validates :email, presence: true, uniqueness: true

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  validates :cpf, length: { minimum: 11, maximum: 11 }, if: -> { password.present? }

end
