# Seed do Livros pra Vida. Pode rodar quantas vezes quiser: nada é duplicado
# e nenhuma senha existente é alterada.
#
#   bin/rails db:seed                          # desenvolvimento / teste
#   SEED_DEMO_USERS=true bin/rails db:seed     # produção (cria os usuários de demonstração)
#   SEED_DEMO_PASSWORD=outraSenha123 ...       # opcional: define a senha dos usuários de demonstração
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

# --- Catálogo da loja (livros que recebem avaliação pública) -----------------
# Os títulos e autores precisam ser iguais aos de docs/src/Catalogo.html, porque o
# front liga cada livro da página ao registro daqui pelo título.
catalogo = [
  [ "O Código Da Vinci",           "Dan Brown" ],
  [ "Anjos e Demônios",            "Dan Brown" ],
  [ "A Ilha do Tesouro",           "R. L. Stevenson" ],
  [ "Orgulho e Preconceito",       "Jane Austen" ],
  [ "É Assim que Começa",          "Colleen Hoover" ],
  [ "A Menina que Roubava Livros", "Markus Zusak" ],
  [ "Duna",                        "Frank Herbert" ],
  [ "O Hobbit",                    "J.R.R. Tolkien" ],
  [ "O Iluminado",                 "Stephen King" ],
  [ "O Alquimista",                "Paulo Coelho" ]
]

catalogo.each do |titulo, autor|
  CatalogBook.find_or_create_by!(title: titulo) { |livro| livro.author_name = autor }
end
puts "Livros do catálogo: #{CatalogBook.count}"

# --- Usuários de demonstração, estantes privadas e livros --------------------
criar_demo = !Rails.env.production? || ENV["SEED_DEMO_USERS"] == "true"

unless criar_demo
  puts "Produção: usuários, estantes e livros de demonstração NÃO foram criados."
  puts "Para criá-los: SEED_DEMO_USERS=true bin/rails db:seed"
  return
end

senha_demo = ENV["SEED_DEMO_PASSWORD"].presence || SecureRandom.alphanumeric(16)
senha_foi_gerada = ENV["SEED_DEMO_PASSWORD"].blank?
senha_usada = false

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
      password: senha_demo,
      password_confirmation: senha_demo
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
