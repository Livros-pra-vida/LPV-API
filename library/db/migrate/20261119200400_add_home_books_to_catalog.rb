class AddHomeBooksToCatalog < ActiveRecord::Migration[8.1]
  # Os livros da página inicial agora existem no catálogo, para o carrinho usar o preço do banco.
  LIVROS = [
    [ "The Midnight Library", "Matt Haig", "Ficção", 49.90, "9780525559474", "Entre a vida e a morte existe uma biblioteca onde cada livro é uma vida que Nora poderia ter vivido." ],
    [ "Sapiens", "Yuval Noah Harari", "História", 54.90, "9780062316097", "Uma breve história da humanidade, da Idade da Pedra até as revoluções que moldaram o mundo atual." ],
    [ "O Nome do Vento", "Patrick Rothfuss", "Fantasia", 59.90, "9780756404741", "Kvothe conta a própria história: de menino do circo a um dos magos mais lendários do seu mundo." ],
    [ "Cem Anos de Solidão", "Gabriel García Márquez", "Clássico", 44.90, "9780060883287", "Sete gerações da família Buendía na mítica Macondo, em uma das obras-primas do realismo mágico." ],
    [ "Beloved", "Toni Morrison", "Drama", 47.90, "9781400033416", "Sethe, ex-escravizada, é assombrada pelo passado e pela presença misteriosa de Beloved." ],
    [ "A Montanha Mágica", "Thomas Mann", "Clássico", 68.90, "9780679772873", "Uma visita de três semanas a um sanatório nos Alpes se transforma em sete anos de reflexão." ],
    [ "Pachinko", "Min Jin Lee", "Drama", 52.90, "9781455563937", "Quatro gerações de uma família coreana que imigra para o Japão em busca de uma vida melhor." ],
    [ "O Morro dos Ventos Uivantes", "Emily Brontë", "Romance", 38.90, "9780141439556", "A paixão intensa e destrutiva entre Heathcliff e Catherine nos campos de Yorkshire." ],
    [ "Kindred", "Octavia E. Butler", "Ficção Científica", 46.90, "9780807083697", "Dana é levada repetidamente do século XX para uma fazenda escravista do século XIX." ],
    [ "As Correções", "Jonathan Franzen", "Drama", 55.90, "9780312421274", "Os Lambert tentam reunir a família para um último Natal enquanto cada um enfrenta suas crises." ]
  ].freeze

  def up
    LIVROS.each do |titulo, autor, genero, preco, isbn, sinopse|
      execute <<~SQL
        INSERT INTO catalog_books (title, author_name, genre, price, image_url, synopsis, created_at, updated_at)
        SELECT #{quote(titulo)}, #{quote(autor)}, #{quote(genero)}, #{preco},
               #{quote("https://covers.openlibrary.org/b/isbn/#{isbn}-L.jpg")}, #{quote(sinopse)}, NOW(), NOW()
        WHERE NOT EXISTS (SELECT 1 FROM catalog_books WHERE LOWER(title) = LOWER(#{quote(titulo)}))
      SQL
    end
  end

  def down
    # Não apaga: um admin pode ter editado ou outras tabelas podem apontar para esses livros.
  end

  private

  def quote(valor)
    connection.quote(valor)
  end
end
