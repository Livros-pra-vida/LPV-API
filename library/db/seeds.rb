# db/seeds.rb

puts "🧹 Limpando registros antigos..."
News.destroy_all if defined?(News)
BookListing.destroy_all if defined?(BookListing)
Book.destroy_all if defined?(Book)
Author.destroy_all if defined?(Author)
Bookcase.destroy_all if defined?(Bookcase)

puts "📚 Criando Estante Padrão..."
estante = Bookcase.create!(name: "Estante Principal da Loja", limit: 1000)

puts "👤 Garantindo Usuário Administrador..."
admin = User.find_by(email: "admin@livrospravida.com") || User.create!(
  username: "admin",
  email: "admin@livrospravida.com",
  password: "admin123",
  password_confirmation: "admin123",
  cpf: "00000000000",
  telefone: "61999999999",
  admin: true
)

capas = {
  lotr: "https://covers.openlibrary.org/b/id/12645114-L.jpg",
  duna: "https://covers.openlibrary.org/b/id/12547148-L.jpg",
  orwell: "https://covers.openlibrary.org/b/id/12711011-L.jpg",
  hobbit: "https://covers.openlibrary.org/b/id/12001569-L.jpg",
  clean_code: "https://covers.openlibrary.org/b/id/12539092-L.jpg",
  sapiens: "https://covers.openlibrary.org/b/id/12695280-L.jpg",
  hp: "https://covers.openlibrary.org/b/id/10521270-L.jpg",
  got: "https://covers.openlibrary.org/b/id/10232402-L.jpg",
  sherlock: "https://covers.openlibrary.org/b/id/12582875-L.jpg",
  alchemist: "https://covers.openlibrary.org/b/id/12833522-L.jpg"
}

puts "📖 Cadastrando 20 Livros no CATÁLOGO OFICIAL DA LOJA..."

livros_catalogo = [
  { title: "O Senhor dos Anéis: A Sociedade do Anel", author: "J.R.R. Tolkien", genre: "Fantasia", price: 59.90, featured: true, description: "Na Terceira Era da Terra-média, Frodo Bolseiro recebe a missão de destruir o Um Anel.", image_url: capas[:lotr] },
  { title: "Duna", author: "Frank Herbert", genre: "Ficção Científica", price: 69.90, featured: true, description: "Paul Atreides precisa sobreviver no planeta árido Arrakis.", image_url: capas[:duna] },
  { title: "1984", author: "George Orwell", genre: "Ficção Científica", price: 34.90, featured: true, description: "A assustadora distopia sobre o Grande Irmão.", image_url: capas[:orwell] },
  { title: "O Hobbit", author: "J.R.R. Tolkien", genre: "Fantasia", price: 44.90, featured: true, description: "A aventura inesquecível de Bilbo Bolseiro junto com treze anões.", image_url: capas[:hobbit] },
  { title: "Código Limpo (Clean Code)", author: "Robert C. Martin", genre: "Desenvolvimento/Filosofia", price: 89.90, featured: true, description: "Boas práticas e refatoração essenciais para devs.", image_url: capas[:clean_code] },
  { title: "Sapiens: Uma Breve História da Humanidade", author: "Yuval Noah Harari", genre: "História/Biografia", price: 64.90, featured: true, description: "Como o Homo Sapiens conquistou a Terra.", image_url: capas[:sapiens] },
  { title: "Harry Potter e a Pedra Filosofal", author: "J.K. Rowling", genre: "Fantasia", price: 49.90, featured: false, description: "O garoto descobre que é um bruxo aceito em Hogwarts.", image_url: capas[:hp] },
  { title: "A Guerra dos Tronos", author: "George R.R. Martin", genre: "Fantasia", price: 74.90, featured: false, description: "A disputa pelo Trono de Ferro entre as grandes casas.", image_url: capas[:got] },
  { title: "Sherlock Holmes: Um Estudo em Vermelho", author: "Arthur Conan Doyle", genre: "Terror/Mistério", price: 24.90, featured: false, description: "O primeiro caso de Sherlock Holmes e Dr. Watson.", image_url: capas[:sherlock] },
  { title: "O Alquimista", author: "Paulo Coelho", genre: "Desenvolvimento/Filosofia", price: 32.90, featured: false, description: "A jornada mística do jovem pastor Santiago.", image_url: capas[:alchemist] },
  { title: "Duna: Segunda Parte", author: "Frank Herbert", genre: "Ficção Científica", price: 65.00, featured: false, description: "A continuação da saga épica de Arrakis.", image_url: capas[:duna] },
  { title: "O Senhor dos Anéis: As Duas Torres", author: "J.R.R. Tolkien", genre: "Fantasia", price: 59.90, featured: false, description: "A Sociedade do Anel foi dissolvida.", image_url: capas[:lotr] },
  { title: "O Senhor dos Anéis: O Retorno do Rei", author: "J.R.R. Tolkien", genre: "Fantasia", price: 59.90, featured: false, description: "O confronto final entre as forças do bem e do mal.", image_url: capas[:lotr] },
  { title: "O Guia do Mochileiro das Galáxias", author: "Douglas Adams", genre: "Ficção Científica", price: 39.90, featured: false, description: "Aventuras espaciais cômicas após a destruição da Terra.", image_url: capas[:orwell] },
  { title: "A Revolução dos Bichos", author: "George Orwell", genre: "Drama", price: 29.90, featured: false, description: "Sátira sobre a corrupção do poder.", image_url: capas[:orwell] },
  { title: "Neuromancer", author: "William Gibson", genre: "Ficção Científica", price: 42.00, featured: false, description: "O clássico Cyberpunk que previu o ciberespaço.", image_url: capas[:duna] },
  { title: "O Iluminado", author: "Stephen King", genre: "Terror/Mistério", price: 52.90, featured: false, description: "O isolado Hotel Overlook e suas forças sombrias.", image_url: capas[:sherlock] },
  { title: "Orgulho e Preconceito", author: "Jane Austen", genre: "Romance", price: 28.90, featured: false, description: "A relação de Elizabeth Bennet e o Sr. Darcy.", image_url: capas[:alchemist] },
  { title: "Fahrenheit 451", author: "Ray Bradbury", genre: "Ficção Científica", price: 38.00, featured: false, description: "Bombeiros que queimam livros proibidos.", image_url: capas[:orwell] },
  { title: "Dom Casmurro", author: "Machado de Assis", genre: "Romance", price: 22.90, featured: false, description: "Bento Santiago e a dúvida sobre Capitu.", image_url: capas[:alchemist] }
]

livros_catalogo.each do |dados|
  autor = Author.find_or_create_by!(name: dados[:author])
  Book.create!(
    title: dados[:title],
    genre: dados[:genre],
    price: dados[:price],
    description: dados[:description],
    image_url: dados[:image_url],
    featured: dados[:featured],
    rating: 5,
    author_id: autor.id,
    bookcase_id: estante.id
  )
end

puts "🔄 Cadastrando 20 Anúncios P2P (Comprar & Trocar)..."

p2p_anuncios = [
  { title: "Duna - Volume 1 (Seminovo)", author: "Frank Herbert", price: 35.00, description: "Exemplar único para venda ou troca na comunidade.", image_url: capas[:duna] },
  { title: "Box Harry Potter Completo", author: "J.K. Rowling", price: 180.00, description: "Edição em excelente estado de conservação.", image_url: capas[:hp] },
  { title: "O Senhor dos Anéis (Capa Dura)", author: "J.R.R. Tolkien", price: 85.00, description: "Aceito trocas por livros de Programação / TI.", image_url: capas[:lotr] },
  { title: "Clean Code - Código Limpo", author: "Robert C. Martin", price: 55.00, description: "Seminovo, essencial para quem cursa ADS.", image_url: capas[:clean_code] },
  { title: "Sapiens - Yuval Harari", author: "Yuval Noah Harari", price: 30.00, description: "Leitura fluida e sem rasuras.", image_url: capas[:sapiens] },
  { title: "1984 - George Orwell", author: "George Orwell", price: 20.00, description: "Lido apenas uma vez.", image_url: capas[:orwell] },
  { title: "O Hobbit", author: "J.R.R. Tolkien", price: 25.00, description: "Ótimo estado de conservação.", image_url: capas[:hobbit] },
  { title: "A Guerra dos Tronos Vol. 1", author: "George R.R. Martin", price: 40.00, description: "Livro em perfeito estado.", image_url: capas[:got] },
  { title: "Sherlock Holmes Coleção", author: "Arthur Conan Doyle", price: 18.00, description: "Disponível para troca rápida.", image_url: capas[:sherlock] },
  { title: "O Alquimista", author: "Paulo Coelho", price: 15.00, description: "Edição pocket conservada.", image_url: capas[:alchemist] },
  { title: "Duna - Edição Especial", author: "Frank Herbert", price: 45.00, description: "Livro novo na folha.", image_url: capas[:duna] },
  { title: "Clean Architecture", author: "Robert C. Martin", price: 65.00, description: "Livro de TI para troca/venda.", image_url: capas[:clean_code] },
  { title: "Sapiens Ilustrado", author: "Yuval Harari", price: 40.00, description: "Edição em quadrinhos.", image_url: capas[:sapiens] },
  { title: "Harry Potter e o Cálice de Fogo", author: "J.K. Rowling", price: 30.00, description: "Usado, bom estado.", image_url: capas[:hp] },
  { title: "O Silmarillion", author: "J.R.R. Tolkien", price: 35.00, description: "Com mapa original incluso.", image_url: capas[:lotr] },
  { title: "A Revolução dos Bichos", author: "George Orwell", price: 15.00, description: "Edição econômica.", image_url: capas[:orwell] },
  { title: "O Guia do Mochileiro", author: "Douglas Adams", price: 22.00, description: "Ideal para fãs de ficção.", image_url: capas[:orwell] },
  { title: "Fahrenheit 451", author: "Ray Bradbury", price: 25.00, description: "Capa brochura perfeita.", image_url: capas[:orwell] },
  { title: "Dom Casmurro", author: "Machado de Assis", price: 12.00, description: "Clássico para estudantes.", image_url: capas[:alchemist] },
  { title: "Neuromancer Cyberpunk", author: "William Gibson", price: 28.00, description: "Livro seminovo.", image_url: capas[:duna] }
]

p2p_anuncios.each do |p2p|
  BookListing.create!(
    title: p2p[:title],
    author: p2p[:author],
    price: p2p[:price],
    description: p2p[:description],
    image_url: p2p[:image_url],
    featured: false,
    user_id: admin.id
  )
end

puts "📰 Cadastrando Notícias Literárias & Geek..."

noticias = [
  {
    title: "Nova adaptação de Duna para os games ganha trailer surpreendente na Gamescom",
    source: "IGN Brasil",
    link_url: "https://br.ign.com",
    image_url: "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&auto=format&fit=crop&q=60",
    description: "O universo criado por Frank Herbert expande suas fronteiras com um MMO de sobrevivência em Arrakis que promete revolucionar a indústria geek.",
    featured: true
  },
  {
    title: "Mercado Editorial Brasileiro registra crescimento de 18% em vendas de livros de Ficção e TI",
    source: "PublishNews",
    link_url: "https://www.publishnews.com.br",
    image_url: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&auto=format&fit=crop&q=60",
    description: "Pesquisa aponta alta demanda por obras clássicas de Fantasia e livros técnicos de arquitetura de software entre jovens universitários.",
    featured: true
  },
  {
    title: "Série baseada em O Senhor dos Anéis confirma gravação da nova temporada",
    source: "Jovem Nerd",
    link_url: "https://jovemnerd.com.br",
    image_url: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&auto=format&fit=crop&q=60",
    description: "Produção épica trará novos personagens clássicos escritos por Tolkien e promete batalhas ainda maiores na Terra-média.",
    featured: true
  },
  {
    title: "Feira Internacional do Livro anuncia área dedicada exclusivamente a trocas P2P de leitores",
    source: "Folha Literária",
    link_url: "https://www.folha.uol.com.br",
    image_url: "https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=500&auto=format&fit=crop&q=60",
    description: "Plataformas comunitárias ganham destaque em estandes dedicados ao consumo consciente e economia circular de acervos pessoais.",
    featured: false
  }
]

if defined?(News)
  noticias.each do |n|
    News.create!(
      title: n[:title],
      source: n[:source],
      link_url: n[:link_url],
      image_url: n[:image_url],
      description: n[:description],
      featured: n[:featured]
    )
  end
end

puts "🎉 SUCESSO! Banco de dados completamente povoado!"