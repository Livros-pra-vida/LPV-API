require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Library
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
<<<<<<< HEAD

    # Fuso e idioma do Brasil (datas das mensagens e pedidos).
    config.time_zone = "Brasilia"

    # ----- Criptografia dos dados sensíveis no banco (Active Record Encryption, AES-256-GCM) -----
    # Campos criptografados: chat global e privado, CPF, telefone, endereço e endereço dos pedidos.
    # As 3 chaves vêm de variáveis de ambiente (arquivo .env no seu PC, "Environment" no Render).
    # Para gerar chaves novas:  bin/rails db:encryption:init
    # ATENÇÃO: se perder ou trocar as chaves, os dados já criptografados NÃO podem mais ser lidos.
    chaves = {
      primary_key: ENV["ENCRYPTION_PRIMARY_KEY"],
      deterministic_key: ENV["ENCRYPTION_DETERMINISTIC_KEY"],
      key_derivation_salt: ENV["ENCRYPTION_KEY_DERIVATION_SALT"]
    }
    if Rails.env.test? && chaves.values.any?(&:blank?)
      # Chaves fixas só para os testes automáticos (nunca usadas com dados reais).
      chaves = { primary_key: "chave-de-teste-" * 3, deterministic_key: "deterministica-" * 3, key_derivation_salt: "sal-de-teste-" * 3 }
    end
    if chaves.values.all?(&:present?)
      chaves.each { |nome, valor| config.active_record.encryption.public_send("#{nome}=", valor) }
    else
      warn "[LPV] Chaves de criptografia ausentes no .env: chat e dados pessoais não vão salvar. Veja o .env.example."
    end
    # Dados antigos (gravados antes da criptografia) continuam legíveis até rodar: bin/rails lpv:criptografar
    config.active_record.encryption.support_unencrypted_data = true
=======
>>>>>>> 821dca3581cf39540ec51ae425d239e22b7d4426
  end
end
