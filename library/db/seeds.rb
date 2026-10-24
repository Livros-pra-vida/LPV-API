# db/seeds.rb

# 1. Garantir Usuário Admin Principal
admin = User.find_or_initialize_by(email: 'admin@livrospravida.com')

admin.assign_attributes(
  username: 'admin',
  cpf: '12345678901',
  password: 'admin123',
  password_confirmation: 'admin123',
  admin: true
)

if admin.save
  puts "✅ Usuário Admin garantido no banco: #{admin.email}"
else
  puts "⚠️ Erro ao salvar Admin: #{admin.errors.full_messages.join(', ')}"
end

# 2. Anúncios de Exemplo para a Comunidade P2P
if defined?(BookListing) && admin.persisted?
  begin
    BookListing.find_or_create_by!(title: "O Senhor dos Anéis - A Sociedade do Anel", user: admin) do |bl|
      bl.author = "J.R.R. Tolkien" if bl.respond_to?(:author=)
      bl.price = 45.00 if bl.respond_to?(:price=)
      bl.featured = true if bl.respond_to?(:featured=)
      bl.image_url = "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80" if bl.respond_to?(:image_url=)
    end
    puts "🔄 Anúncio P2P de exemplo criado."
  rescue => e
    puts "⚠️ Ignorando erro ao criar anúncio P2P: #{e.message}"
  end
end