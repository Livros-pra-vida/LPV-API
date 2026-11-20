# Be sure to restart your server when you modify this file.

# Quais sites podem chamar a API pelo navegador.
# Antes estava "*" (qualquer site do mundo). Agora só o front oficial e o localhost.
# Para liberar outros endereços, defina CORS_ORIGINS separados por vírgula, por exemplo:
#   CORS_ORIGINS=https://livros-pra-vida.github.io,https://meu-dominio.com.br
origens_permitidas = ENV.fetch("CORS_ORIGINS", "https://livros-pra-vida.github.io")
                        .split(",").map(&:strip).reject(&:empty?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*origens_permitidas, %r{\Ahttp://(localhost|127\.0\.0\.1)(:\d+)?\z})

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
