# db/seeds.rb

# Criação do Usuário Administrador Principal
admin = User.find_or_initialize_by(email: 'admin@livrospravida.com')

admin.assign_attributes(
  username: 'admin',
  cpf: '12345678901', # 11 dígitos exigidos pela validação
  password: 'admin123',
  password_confirmation: 'admin123',
  admin: true
)

if admin.save
  puts "✅ Usuário Admin garantido no banco: #{admin.email}"
else
  puts "⚠️ Erro ao salvar Admin: #{admin.errors.full_messages.join(', ')}"
end

# Livros de Exemplo para o Catálogo da Loja
if defined?(Book)
  books_data = [
    { title: "Dom Casmurro", author: "Machado de Assis", price: 34.90, image_url: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=400&q=80" },
    { title: "O Alquimista", author: "Paulo Coelho", price: 29.90, image_url: "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80" },
    { title: "1984", author: "George Orwell", price: 42.00, image_url: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=400&q=80" }
  ]

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
if defined?(BookListing) && admin.persisted?
  BookListing.find_or_create_by!(title: "O Senhor dos Anéis - A Sociedade do Anel", user: admin) do |bl|
    bl.author = "J.R.R. Tolkien"
    bl.price = 45.00
    bl.featured = true
    bl.image_url = "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80"
  end
  puts "🔄 Anúncio P2P de exemplo criado."
end