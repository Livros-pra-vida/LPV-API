class EncryptExistingData < ActiveRecord::Migration[8.1]
  # Criptografa o que já estava no banco antes desta versão: mensagens do chat global,
  # CPF e telefone dos usuários. Roda sozinha no deploy (junto com as outras migrações).
  #
  # Se as chaves ENCRYPTION_* não estiverem configuradas, ela só avisa e não faz nada
  # (o deploy continua). Depois de configurar as chaves, rode: bin/rails lpv:criptografar
  class Message < ApplicationRecord
    self.table_name = "messages"
    encrypts :content
  end

  class User < ApplicationRecord
    self.table_name = "users"
    encrypts :cpf, :telefone, :cep, :rua, :numero, :bairro, :cidade
  end

  def up
    unless chaves_configuradas?
      say "ATENÇÃO: chaves ENCRYPTION_* ausentes. Os dados antigos NÃO foram criptografados.", true
      say "Configure as 3 variáveis no Render e rode: bin/rails lpv:criptografar", true
      return
    end

    { Message => "mensagens", User => "usuários" }.each do |modelo, nome|
      modelo.reset_column_information
      total = 0
      falhas = []
      modelo.find_each do |registro|
        registro.encrypt
        total += 1
      rescue StandardError => e
        falhas << "#{registro.id} (#{e.class})"
      end
      say "#{nome}: #{total} criptografado(s)", true
      say "#{nome} com problema (ficaram como estavam): #{falhas.join(', ')}", true if falhas.any?
    end
  end

  def down
    # Não descriptografa: os dados continuam legíveis pela API com as mesmas chaves.
  end

  private

  def chaves_configuradas?
    config = ActiveRecord::Encryption.config
    [ config.primary_key, config.key_derivation_salt ].all?(&:present?)
  rescue StandardError
    false
  end
end
