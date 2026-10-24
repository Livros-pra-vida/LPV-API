# db/seeds.rb

puts "🧹 Limpando registros antigos do banco de dados..."
News.destroy_all if defined?(News)
BookListing.destroy_all if defined?(BookListing)
Book.destroy_all if defined?(Book)
Author.destroy_all if defined?(Author)
Bookcase.destroy_all if defined?(Bookcase)

puts "📚 Criando Estante Padrão..."
estante = Bookcase.create!(name: "Estante Principal da Loja", limit: 1000)

puts "👤 Criando ou encontrando o Usuário Administrador..."
admin = User.find_by(email: "admin@livrospravida.com") || User.create!(
  username: "admin",
  email: "admin@livrospravida.com",
  password: "admin123",
  password_confirmation: "admin123",
  cpf: "00000000000",
  telefone: "61999999999",
  admin: true
)

puts "📖 Cadastrando 20 Livros no Catálogo Oficial (Loja)..."

livros_catalogo = [
  { title: "O Senhor dos Anéis: A Sociedade do Anel", author: "J.R.R. Tolkien", genre: "Fantasia", price: 59.90, featured: true, description: "Na Terceira Era da Terra-média, o Hobite Frodo Bolseiro recebe a missão de destruir o Um Anel.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81h2gWPTYJL.jpg" },
  { title: "Duna", author: "Frank Herbert", genre: "Ficção Científica", price: 69.90, featured: true, description: "Paul Atreides precisa sobreviver no planeta árido Arrakis para garantir o futuro da humanidade.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81zE42gT33L.jpg" },
  { title: "1984", author: "George Orwell", genre: "Ficção Científica", price: 34.90, featured: true, description: "A assustadora distopia sobre o Grande Irmão e o controle total do Estado sobre a vida individual.", image_url: "https://images-na.ssl-images-amazon.com/images/I/819js3EQwbL.jpg" },
  { title: "O Hobbit", author: "J.R.R. Tolkien", genre: "Fantasia", price: 44.90, featured: true, description: "A aventura inesquecível de Bilbo Bolseiro junto com treze anões e o mago Gandalf.", image_url: "https://images-na.ssl-images-amazon.com/images/I/91M9xPfd13L.jpg" },
  { title: "Código Limpo (Clean Code)", author: "Robert C. Martin", genre: "Desenvolvimento/Filosofia", price: 89.90, featured: true, description: "Boas práticas, refatoração e padrões de projeto essenciais para todo desenvolvedor de software.", image_url: "https://images-na.ssl-images-amazon.com/images/I/71T1K4G+M3L.jpg" },
  { title: "O Programador Pragmático", author: "Andrew Hunt", genre: "Desenvolvimento/Filosofia", price: 95.00, featured: true, description: "Da responsabilidade pessoal ao desenvolvimento de carreira no mundo da tecnologia.", image_url: "https://images-na.ssl-images-amazon.com/images/I/71f743sOPoL.jpg" },
  { title: "A Revolução dos Bichos", author: "George Orwell", genre: "Drama", price: 29.90, featured: false, description: "Uma sátira genial sobre o poder, a corrupção e a revolução dos animais da fazenda.", image_url: "https://images-na.ssl-images-amazon.com/images/I/91BS2O1S-yL.jpg" },
  { title: "O Nome do Vento", author: "Patrick Rothfuss", genre: "Fantasia", price: 54.90, featured: false, description: "A trajetória de Kvothe, da sua infância em uma trupe de teatro à fama como mago épico.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81iP4-3O6kL.jpg" },
  { title: "Neuromancer", author: "William Gibson", genre: "Ficção Científica", price: 42.00, featured: false, description: "O clássico divisor de águas do gênero Cyberpunk que previu a internet e a inteligência artificial.", image_url: "https://images-na.ssl-images-amazon.com/images/I/91Rst42XJmL.jpg" },
  { title: "Sapiens: Uma Breve História da Humanidade", author: "Yuval Noah Harari", genre: "História/Biografia", price: 64.90, featured: false, description: "Como a espécie Homo Sapiens conquistou a Terra através da linguagem, ficção e cooperação.", image_url: "https://images-na.ssl-images-amazon.com/images/I/713jIoMO3UL.jpg" },
  { title: "O Guia do Mochileiro das Galáxias", author: "Douglas Adams", genre: "Ficção Científica", price: 39.90, featured: false, description: "As aventuras cômicas e espaciais de Arthur Dent após a destruição da Terra.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81L7-o7uI0L.jpg" },
  { title: "Harry Potter e a Pedra Filosofal", author: "J.K. Rowling", genre: "Fantasia", price: 49.90, featured: false, description: "O garoto órfão descobre no seu aniversário de 11 anos que é um bruxo aceito em Hogwarts.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81iqZ2HHD6L.jpg" },
  { title: "O Iluminado", author: "Stephen King", genre: "Terror/Mistério", price: 52.90, featured: false, description: "Jack Torrance aceita o emprego de zelador no isolado Hotel Overlook com trágicas consequências.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81pCInP7QmL.jpg" },
  { title: "A Guerra dos Tronos", author: "George R.R. Martin", genre: "Fantasia", price: 74.90, featured: false, description: "A disputa pelo Trono de Ferro entre as grandes casas nobres do continente de Westeros.", image_url: "https://images-na.ssl-images-amazon.com/images/I/91dSM9D26DL.jpg" },
  { title: "Orgulho e Preconceito", author: "Jane Austen", genre: "Romance", price: 28.90, featured: false, description: "A relação tempestuosa entre Elizabeth Bennet e o misterioso e orgulhoso Sr. Darcy.", image_url: "https://images-na.ssl-images-amazon.com/images/I/71Q1tPupKFL.jpg" },
  { title: "Fahrenheit 451", author: "Ray Bradbury", genre: "Ficção Científica", price: 38.00, featured: false, description: "Em um futuro opressivo, os bombeiros têm como única função queimar livros proibidos.", image_url: "https://images-na.ssl-images-amazon.com/images/I/71OFqSRFDgL.jpg" },
  { title: "Os Miseráveis", author: "Victor Hugo", genre: "Drama", price: 79.90, featured: false, description: "A jornada de redenção de Jean Valjean na França conturbada do século XIX.", image_url: "https://images-na.ssl-images-amazon.com/images/I/81k3fO-8FAL.jpg" },
  { title: "O Alquimista", author: "Paulo Coelho", genre: "Desenvolvimento/Filosofia", price: 32.90, featured: false, description: "A história mística de Santiago, o jovem pastor da Andaluzia em busca de sua Lenda Pessoal.", image_url: "https://images-na.ssl-images-amazon.com/images/I/71aFt4+OTOL.jpg" },
  { title: "Sherlock Holmes: Um Estudo em Vermelho", author: "Arthur Conan Doyle", genre: "Terror/Mistério", price: 24.90, featured: false, description: "O primeiro caso da dupla lendária Sherlock Holmes e Dr. John Watson.", image_url: "https://images-na.ssl-images-amazon.com/images/I/813B1C5zWpL.jpg" },
  { title: "Dom Casmurro", author: "Machado de Assis", genre: "Romance", price: 22.90, featured: false, description: "Bento Santiago relembra sua juventude e seu amor por Capitu: a dúvida eterna sobre a traição.", image_url: "https://images-na.ssl-images-amazon.com/images/I/61NfXp70r8L.jpg" }
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
    rating: 5.0,
    author_id: autor.id,
    bookcase_id: estante.id
  )
end

puts "🔄 Cadastrando 20 Anúncios P2P da Comunidade (Comprar & Trocar)..."

p2p_anuncios = [
  { title: "Duna - Volume 1 (Lido 1x, Seminovo)", price: 35.00, condition: "Seminovo", intent: "Venda/Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/81zE42gT33L.jpg" },
  { title: "Box Harry Potter Completo 7 Livros", price: 180.00, condition: "Usado - Bom Estado", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/81iqZ2HHD6L.jpg" },
  { title: "O Problema dos Três Corpos (Capa Dura)", price: 45.00, condition: "Novo", intent: "Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/91N44B0S5sL.jpg" },
  { title: "Entendendo Algoritmos - Ilustrado", price: 50.00, condition: "Seminovo", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/71V23sMTh3L.jpg" },
  { title: "Sapiens - Yuval Harari", price: 30.00, condition: "Usado", intent: "Venda/Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/713jIoMO3UL.jpg" },
  { title: "O Silmarillion - J.R.R. Tolkien", price: 40.00, condition: "Seminovo", intent: "Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/81-f2M3Tz9L.jpg" },
  { title: "Mitologia Nórdica - Neil Gaiman", price: 25.00, condition: "Seminovo", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/81W4IskMvGL.jpg" },
  { title: "A Garota no Trem", price: 20.00, condition: "Usado", intent: "Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/81S2eKSpP7L.jpg" },
  { title: "Cem Anos de Solidão - Gabriel García Márquez", price: 32.00, condition: "Seminovo", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/81S1E8n2UGL.jpg" },
  { title: "Fundação - Isaac Asimov (Trilogia)", price: 75.00, condition: "Seminovo", intent: "Venda/Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/819T8mGfveL.jpg" },
  { title: "O Hobbit - Edição Especial de Luxo", price: 60.00, condition: "Novo na Folha", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/91M9xPfd13L.jpg" },
  { title: "Estruturas de Dados e Algoritmos em Java", price: 85.00, condition: "Usado - Marcas de Lápis", intent: "Venda/Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/71T1K4G+M3L.jpg" },
  { title: "O Poder do Hábito - Charles Duhigg", price: 28.00, condition: "Seminovo", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/818q-L0Xo1L.jpg" },
  { title: "A Bússola de Ouro - Philip Pullman", price: 22.00, condition: "Usado", intent: "Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/81bS8iE1oEL.jpg" },
  { title: "Miseráveis - Victor Hugo Vol. 1 e 2", price: 50.00, condition: "Seminovo", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/81k3fO-8FAL.jpg" },
  { title: "Cultura Code - Daniel Coyle", price: 30.00, condition: "Novo", intent: "Venda/Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/71aFt4+OTOL.jpg" },
  { title: "Coraline - Neil Gaiman (Edição Ilustrada)", price: 38.00, condition: "Seminovo", intent: "Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/81pCInP7QmL.jpg" },
  { title: "Maus - Art Spiegelman", price: 42.00, condition: "Seminovo", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/81BS2O1S-yL.jpg" },
  { title: "Drácula - Bram Stoker (DarkSide)", price: 48.00, condition: "Novo com Lacre", intent: "Venda", image_url: "https://images-na.ssl-images-amazon.com/images/I/813B1C5zWpL.jpg" },
  { title: "O Milagre da Manhã", price: 18.00, condition: "Usado", intent: "Troca", image_url: "https://images-na.ssl-images-amazon.com/images/I/61NfXp70r8L.jpg" }
]

p2p_anuncios.each do |p2p|
  BookListing.create!(
    title: p2p[:title],
    price: p2p[:price],
    condition: p2p[:condition],
    intent: p2p[:intent],
    image_url: p2p[:image_url],
    user_id: admin.id
  )
end

puts "📰 Cadastrando Notícias Literárias & Geek na aba Novidades..."

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

puts "🎉 SUCESSO ABSOLUTO! Banco de dados PostgreSQL completamente povoado para a apresentação!"