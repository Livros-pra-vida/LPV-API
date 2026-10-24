# Criação do Utilizador Administrador Principal
admin_email = 'admin@livrospravida.com'
admin = User.find_by(email: admin_email) || User.find_by(username: 'admin')

if admin.nil?
  admin = User.create!(
    username: 'admin',
    email: admin_email,
    password: 'admin123', # Altera para a tua senha preferida de admin
    password_confirmation: 'admin123',
    admin: true
  )
  puts "✅ Utilizador Admin criado com sucesso: #{admin.email}"
else
  admin.update!(admin: true)
  puts "ℹ️ Utilizador Admin já existente. Permissão de admin garantida."
end

# Livros de Exemplo para o Catálogo Oficial da Loja
books_data = [
  {
    title: "Dom Casmurro",
    author: "Machado de Assis",
    price: 34.90,
    image_url: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=400&q=80"
  },
  {
    title: "O Alquimista",
    author: "Paulo Coelho",
    price: 29.90,
    image_url: "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80"
  },
  {
    title: "1984",
    author: "George Orwell",
    price: 42.00,
    image_url: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=400&q=80"
  }
]

if defined?(Book)
  books_data.each do |data|
    Book.find_or_create_by!(title: data[:title]) do |b|
      b.author = data[:author]
      b.price = data[:price]
      b.image_url = data[:image_url]
    end
  end
  puts "📚 Livros do acervo garantidos."
end

# Anúncios de Exemplo para a Comunidade P2P
if defined?(BookListing)
  BookListing.find_or_create_by!(title: "O Senhor dos Anéis - A Sociedade do Anel", user: admin) do |bl|
    bl.author = "J.R.R. Tolkien"
    bl.price = 45.00
    bl.featured = true
    bl.image_url = "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80"
  end
  puts "🔄 Anúncios P2P de exemplo criados."
end