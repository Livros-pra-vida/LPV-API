class AddDetailsToCatalogBooks < ActiveRecord::Migration[8.1]
  # Dados que antes ficavam fixos em docs/src/Catalogo.html. Agora o catálogo vive no banco,
  # para o administrador poder adicionar e excluir livros para todos os usuários.
  DADOS_INICIAIS = {
    "O Código Da Vinci"           => [ "Ação/Aventura", 42.90, "9780307474278", "Um assassinato no Museu do Louvre traz à tona uma conspiração para ocultar um segredo sagrado protegido por uma sociedade secreta durante séculos." ],
    "Anjos e Demônios"            => [ "Ação/Aventura", 39.90, "9780743493468", "Robert Langdon tenta deter uma antiga fraternidade secreta que ameaça destruir a Cidade do Vaticano usando uma nova arma devastadora." ],
    "A Ilha do Tesouro"           => [ "Ação/Aventura", 29.90, "9780451527042", "O jovem Jim Hawkins encontra um mapa do tesouro e embarca em uma aventura inesquecível enfrentando piratas e o temível Long John Silver." ],
    "Orgulho e Preconceito"       => [ "Romance", 34.90, "9780141439518", "Uma história clássica sobre a relação entre a perspicaz Elizabeth Bennet e o orgulhoso Sr. Darcy na Inglaterra do século XIX." ],
    "É Assim que Começa"          => [ "Romance", 49.90, "9781668001226", "Lily Bloom continua navegando pelos desafios da vida após se separar, descobrindo novos caminhos e reencontrando o seu primeiro amor." ],
    "A Menina que Roubava Livros" => [ "Drama", 42.00, "9780375842207", "Narrado pela Morte, acompanha a história da jovem Liesel Meminger durante a Segunda Guerra Mundial, encontrando alento nos livros que rouba." ],
    "Duna"                        => [ "Ficção Científica", 69.90, "9780441172719", "Em um planeta desértico disputado por famílias nobres, o jovem Paul Atreides enfrenta política, religião e a natureza para cumprir seu destino." ],
    "O Hobbit"                    => [ "Fantasia", 49.90, "9780547928227", "Bilbo Bolseiro é arrastado para uma jornada épica com anões e o mago Gandalf para reconquistar o tesouro guardado pelo dragão Smaug." ],
    "O Iluminado"                 => [ "Terror/Mistério", 54.90, "9780307743657", "Jack Torrance aceita o emprego de caseiro num hotel isolado durante o inverno, mas forças misteriosas começam a afetar sua sanidade." ],
    "O Alquimista"                => [ "Desenvolvimento/Filosofia", 34.90, "9780062315007", "A jornada do jovem pastor Santiago em busca de um tesouro nas pirâmides do Egito, aprendendo a escutar o seu coração e seguir seus sonhos." ]
  }.freeze

  def up
    add_column :catalog_books, :genre, :string
    add_column :catalog_books, :price, :decimal, precision: 10, scale: 2, null: false, default: 0
    add_column :catalog_books, :image_url, :text
    add_column :catalog_books, :synopsis, :text
    # Quem cadastrou o livro (nulo = livro original da loja). Se o usuário sumir, o livro fica.
    add_reference :catalog_books, :user, null: true, foreign_key: { on_delete: :nullify }

    # Livros que já estavam no banco (criados só com título e autor) ganham os dados completos.
    DADOS_INICIAIS.each do |titulo, (genero, preco, isbn, sinopse)|
      execute <<~SQL
        UPDATE catalog_books
        SET genre = #{connection.quote(genero)},
            price = #{preco},
            image_url = #{connection.quote("https://covers.openlibrary.org/b/isbn/#{isbn}-L.jpg")},
            synopsis = #{connection.quote(sinopse)}
        WHERE lower(title) = lower(#{connection.quote(titulo)}) AND genre IS NULL
      SQL
    end
  end

  def down
    remove_reference :catalog_books, :user, foreign_key: true
    remove_column :catalog_books, :synopsis
    remove_column :catalog_books, :image_url
    remove_column :catalog_books, :price
    remove_column :catalog_books, :genre
  end
end
