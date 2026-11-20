class EncryptExistingData < ActiveRecord::Migration[8.1]
  # Criptografa o que já estava no banco antes desta versão: mensagens do chat global,
  # CPF e telefone dos usuários. Roda sozinha no deploy (junto com as outras migrações).
  # Precisa das 3 variáveis ENCRYPTION_* configuradas; sem elas a migração para com erro.
  class Message < ApplicationRecord
    self.table_name = "messages"
    encrypts :content
  end

  class User < ApplicationRecord
    self.table_name = "users"
    encrypts :cpf, :telefone, :cep, :rua, :numero, :bairro, :cidade
  end

  def up
    [ Message, User ].each do |modelo|
      modelo.reset_column_information
      modelo.find_each(&:encrypt)
    end
  end

  def down
    [ Message, User ].each do |modelo|
      modelo.reset_column_information
      modelo.find_each(&:decrypt)
    end
  end
end
