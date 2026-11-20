# Seed do Livros pra Vida. Pode rodar quantas vezes quiser: nada é duplicado
# e nenhuma senha existente é alterada.
#
#   bin/rails db:seed                          # desenvolvimento / teste
#   SEED_DEMO_USERS=true bin/rails db:seed     # produção (cria os usuários de demonstração)
<<<<<<< HEAD
#   SEED_DEMO_PASSWORD=OutraSenha@123 ...       # opcional: define a senha dos usuários de demonstração
=======
#   SEED_DEMO_PASSWORD=outraSenha123 ...       # opcional: define a senha dos usuários de demonstração
>>>>>>> 821dca3581cf39540ec51ae425d239e22b7d4426
#
# Em produção, sem SEED_DEMO_USERS=true, só o cadastro de autores é criado
# (contas de demonstração com senha conhecida não devem existir por engano).

# --- Autores (cadastro compartilhado) ---------------------------------------
autores = {
  "Dan Brown"              => "Escritor norte-americano de thrillers de mistério e conspiração.",
  "Robert Louis Stevenson" => "Escritor escocês, autor de A Ilha do Tesouro e O Médico e o Monstro.",
  "Jane Austen"            => "Romancista inglesa, autora de Orgulho e Preconceito e Razão e Sensibilidade.",
  "Colleen Hoover"         => "Autora norte-americana de romances contemporâneos.",
  "Markus Zusak"           => "Escritor australiano, autor de A Menina que Roubava Livros.",
  "Frank Herbert"          => "Escritor norte-americano de ficção científica, criador da série Duna.",
  "J.R.R. Tolkien"         => "Escritor e filólogo inglês, autor de O Hobbit e O Senhor dos Anéis.",
  "Stephen King"           => "Escritor norte-americano de terror e suspense.",
  "Paulo Coelho"           => "Escritor brasileiro, autor de O Alquimista."
}

autores_por_nome = autores.to_h do |nome, descricao|
  autor = Author.find_or_create_by!(name: nome) { |a| a.description = descricao }
  [ nome, autor ]
end
puts "Autores: #{Author.count}"

# --- Catálogo da loja (livros à venda, com avaliação pública) ----------------
# Livros originais da loja (sem dono). O administrador adiciona e exclui outros pela página do
# Catálogo. Atenção: rodar o seed de novo recria um livro original que o admin tenha excluído.
capa = ->(isbn) { "https://covers.openlibrary.org/b/isbn/#{isbn}-L.jpg" }

catalogo = [
  [ "O Código Da Vinci", "Dan Brown", "Ação/Aventura", 42.90, "9780307474278", "Um assassinato no Museu do Louvre traz à tona uma conspiração para ocultar um segredo sagrado protegido por uma sociedade secreta durante séculos." ],
  [ "Anjos e Demônios", "Dan Brown", "Ação/Aventura", 39.90, "9780743493468", "Robert Langdon tenta deter uma antiga fraternidade secreta que ameaça destruir a Cidade do Vaticano usando uma nova arma devastadora." ],
  [ "A Ilha do Tesouro", "R. L. Stevenson", "Ação/Aventura", 29.90, "9780451527042", "O jovem Jim Hawkins encontra um mapa do tesouro e embarca em uma aventura inesquecível enfrentando piratas e o temível Long John Silver." ],
  [ "Orgulho e Preconceito", "Jane Austen", "Romance", 34.90, "9780141439518", "Uma história clássica sobre a relação entre a perspicaz Elizabeth Bennet e o orgulhoso Sr. Darcy na Inglaterra do século XIX." ],
  [ "É Assim que Começa", "Colleen Hoover", "Romance", 49.90, "9781668001226", "Lily Bloom continua navegando pelos desafios da vida após se separar, descobrindo novos caminhos e reencontrando o seu primeiro amor." ],
  [ "A Menina que Roubava Livros", "Markus Zusak", "Drama", 42.00, "9780375842207", "Narrado pela Morte, acompanha a história da jovem Liesel Meminger durante a Segunda Guerra Mundial, encontrando alento nos livros que rouba." ],
  [ "Duna", "Frank Herbert", "Ficção Científica", 69.90, "9780441172719", "Em um planeta desértico disputado por famílias nobres, o jovem Paul Atreides enfrenta política, religião e a natureza para cumprir seu destino." ],
  [ "O Hobbit", "J.R.R. Tolkien", "Fantasia", 49.90, "9780547928227", "Bilbo Bolseiro é arrastado para uma jornada épica com anões e o mago Gandalf para reconquistar o tesouro guardado pelo dragão Smaug." ],
  [ "O Iluminado", "Stephen King", "Terror/Mistério", 54.90, "9780307743657", "Jack Torrance aceita o emprego de caseiro num hotel isolado durante o inverno, mas forças misteriosas começam a afetar sua sanidade." ],
  [ "O Alquimista", "Paulo Coelho", "Desenvolvimento/Filosofia", 34.90, "9780062315007", "A jornada do jovem pastor Santiago em busca de um tesouro nas pirâmides do Egito, aprendendo a escutar o seu coração e seguir seus sonhos." ]
]

catalogo.each do |titulo, autor, genero, preco, isbn, sinopse|
  livro = CatalogBook.find_or_initialize_by(title: titulo)
  # Só preenche livros novos ou ainda sem dados: nunca sobrescreve o que um admin já ajustou.
  if livro.new_record? || livro.genre.blank?
    livro.assign_attributes(author_name: autor, genre: genero, price: preco,
                            image_url: capa.call(isbn), synopsis: sinopse)
    livro.save!
  end
end
puts "Livros do catálogo: #{CatalogBook.count}"

# --- Anúncios de exemplo do Comprar & Trocar (anunciantes fictícios, sem conta) -----
anuncios = [
  { title: "A Biblioteca da Meia-Noite", author_name: "Matt Haig", modality: "Troca", region: "Taguatinga", seller_name: "Carla Mendes", reputation: "4.9 (14 trocas)",
    image_url: "https://http2.mlstatic.com/D_NQ_NP_906176-MLA114707539172_082026-O.webp" },
  { title: "Sapiens: Uma Breve História", author_name: "Yuval N. Harari", modality: "Doação", region: "Águas Claras", seller_name: "Marcos Vinicius", reputation: "5.0 (8 trocas)",
    image_url: "https://m.media-amazon.com/images/I/71-ghLb8qML._AC_UF1000,1000_QL80_.jpg" },
  { title: "Duna", author_name: "Frank Herbert", modality: "Venda", price: 35.00, region: "Asa Sul / Norte", status: "Em Negociacao", seller_name: "Beatriz Lima", reputation: "4.7 (21 vendas)",
    image_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlWw1rpe1Ny4V2JUHvKFh_rPmIFDA1kvLlc2eiUxk--Q_E9nX4B9NzMzY&s=10" },
  { title: "O Pequeno Príncipe", author_name: "Antoine de Saint-Exupéry", modality: "Troca", region: "Taguatinga", seller_name: "Lucas Gabriel", reputation: "4.8 (5 trocas)",
    image_url: "https://cdl-static.s3-sa-east-1.amazonaws.com/covers/gg/9788537814666/o-pequeno-principe-edicao-bolso-de-luxo-traducao-de-andre-telles-e-rodrigo-lacerda-vencedores-do-premio-jabuti.jpg" }
]

anuncios.each do |dados|
  BookListing.find_or_create_by!(title: dados[:title], seller_name: dados[:seller_name], user_id: nil) do |anuncio|
    anuncio.assign_attributes(dados)
  end
end
puts "Anúncios: #{BookListing.count}"

# --- Usuários de demonstração, estantes privadas e livros --------------------
criar_demo = !Rails.env.production? || ENV["SEED_DEMO_USERS"] == "true"

unless criar_demo
  puts "Produção: usuários, estantes e livros de demonstração NÃO foram criados."
  puts "Para criá-los: SEED_DEMO_USERS=true bin/rails db:seed"
  return
end

<<<<<<< HEAD
# Senha gerada já cumpre as regras (maiúscula, número e caractere especial).
senha_demo = ENV["SEED_DEMO_PASSWORD"].presence || "#{SecureRandom.alphanumeric(10)}Aa1!"
senha_foi_gerada = ENV["SEED_DEMO_PASSWORD"].blank?
senha_usada = false

# A API recebe a senha pura e faz o SHA-256 + bcrypt sozinha (veja User#password=).
=======
senha_demo = ENV["SEED_DEMO_PASSWORD"].presence || SecureRandom.alphanumeric(16)
senha_foi_gerada = ENV["SEED_DEMO_PASSWORD"].blank?
senha_usada = false

# O front envia a senha já com hash SHA-256 (hex, 64 caracteres) no login e no cadastro (CryptoJS).
# Por isso o usuário de demonstração é criado com esse hash: ele entra digitando a senha normal.
senha_digest = Digest::SHA256.hexdigest(senha_demo)
>>>>>>> 821dca3581cf39540ec51ae425d239e22b7d4426

# Cada usuário tem as suas próprias estantes. Ninguém vê a estante do outro.
demo = [
  {
    username: "Leitor Demo 1",
    email: "demo1@livrospravida.example",
    estantes: {
      "Favoritos" => { limit: 20, livros: [
        [ "Duna", "Frank Herbert", 5 ],
        [ "O Hobbit", "J.R.R. Tolkien", 5 ],
        [ "O Alquimista", "Paulo Coelho", 4 ],
        [ "Orgulho e Preconceito", "Jane Austen", 5 ]
      ] },
      "Quero ler" => { limit: 10, livros: [
        [ "O Código Da Vinci", "Dan Brown", nil ],
        [ "Anjos e Demônios", "Dan Brown", nil ],
        [ "O Iluminado", "Stephen King", nil ]
      ] }
    }
  },
  {
    username: "Leitor Demo 2",
    email: "demo2@livrospravida.example",
    estantes: {
      "Aventuras e dramas" => { limit: 15, livros: [
        [ "A Ilha do Tesouro", "Robert Louis Stevenson", 4 ],
        [ "A Menina que Roubava Livros", "Markus Zusak", 5 ],
        [ "É Assim que Começa", "Colleen Hoover", 4 ]
      ] }
    }
  }
]

demo.each do |dados|
  usuario = User.find_by(email: dados[:email])

  if usuario
    puts "Usuário já existe, senha mantida: #{dados[:email]}"
  else
    usuario = User.create!(
      username: dados[:username],
      email: dados[:email],
      cpf: "00000000000", # valor fictício, só para passar na validação de tamanho
      admin: false,
<<<<<<< HEAD
      password: senha_demo,
      password_confirmation: senha_demo
=======
      password: senha_digest,
      password_confirmation: senha_digest
>>>>>>> 821dca3581cf39540ec51ae425d239e22b7d4426
    )
    senha_usada = true
    puts "Usuário criado: #{dados[:email]}"
  end

  dados[:estantes].each do |nome_estante, estante_dados|
    estante = usuario.bookcases.find_or_create_by!(name: nome_estante) do |b|
      b.limit = estante_dados[:limit]
    end

    estante_dados[:livros].each do |titulo, nome_autor, nota|
      estante.books.find_or_create_by!(title: titulo, author: autores_por_nome.fetch(nome_autor)) do |livro|
        livro.rating = nota
      end
    end
  end
end

puts "Estantes: #{Bookcase.count} | Livros: #{Book.count} | Usuários: #{User.count}"

if senha_usada
  puts "Senha dos usuários de demonstração: #{senha_demo}" if senha_foi_gerada
  puts "(com SEED_DEMO_PASSWORD definida, a senha é a que você informou)" unless senha_foi_gerada
end
