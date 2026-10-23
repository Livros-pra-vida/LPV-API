Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Permite qualquer origem (incluindo ficheiros locais do browser)

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end