class CreateNewsAdminActionsAndSuspension < ActiveRecord::Migration[8.1]
  # Notícias e lançamentos (antes ficavam fixos em Novidades.html; agora só o ADM publica),
  # registro das ações dos administradores e suspensão de contas.
  NOTICIAS = [
    { kind: "noticia", category: "mangas", featured: true,
      title: "Hunter x Hunter: Shonen Jump traz atualizações oficiais sobre a obra de Togashi",
      summary: "Acompanhe os anúncios detalhados sobre o andamento dos novos capítulos, cronograma de publicação e o forte impacto do retorno do mangá no mercado internacional e brasileiro.",
      source_name: "JBox - Cultura Pop Japonesa", source_url: "https://www.jbox.com.br/?s=Hunter+x+Hunter",
      image_url: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800&auto=format&fit=crop&q=80" },
    { kind: "noticia", category: "livros",
      title: "Prêmio Jabuti divulga novidades e cronograma da edição",
      summary: "A principal premiação da literatura brasileira traz atualizações em suas categorias e prazos para inscrições de editoras e autores independentes.",
      source_name: "Portal PublishNews", source_url: "https://www.publishnews.com.br/busca?q=Pr%C3%AAmio+Jabuti",
      image_url: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&auto=format&fit=crop&q=60" },
    { kind: "noticia", category: "adaptacoes",
      title: "Grandes sucessos literários cotados para adaptação nas telas",
      summary: "Confira os romances e livros de fantasia mais comentados do momento que fecharam contratos para ganhar versões em formato de filme ou série de streaming.",
      source_name: "Portal Omelete", source_url: "https://www.omelete.com.br/busca/?q=livros+adaptados",
      image_url: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=400&auto=format&fit=crop&q=60" },
    { kind: "noticia", category: "livros",
      title: "Balanço e impacto das Bienais do Livro no incentivo à leitura",
      summary: "Uma análise aprofundada sobre como os grandes eventos literários presenciais impulsionam o consumo de livros físicos e aproximam autores do público jovem.",
      source_name: "Portal PublishNews", source_url: "https://www.publishnews.com.br/busca?q=Bienal+do+Livro",
      image_url: "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&auto=format&fit=crop&q=60" },
    { kind: "lancamento", category: "livros", release_date: "2026-12-12",
      title: "Box Edição Especial O Hobbit", summary: "Editora HarperCollins • Capa Dura" },
    { kind: "lancamento", category: "mangas", release_date: "2026-12-18",
      title: "Mangá Jujutsu Kaisen Vol. 28", summary: "Panini Mangás • Lançamento Oficial" },
    { kind: "lancamento", category: "livros", release_date: "2026-12-25",
      title: "Novo Romance de Fantasia Nacional", summary: "Selo Independente • Pré-venda" }
  ].freeze

  def up
    create_table :news_posts do |t|
      t.string :kind, null: false, default: "noticia"     # "noticia" ou "lancamento"
      t.string :category, null: false, default: "livros" # livros, mangas, adaptacoes
      t.string :title, null: false
      t.text :summary
      t.string :source_name
      t.string :source_url
      t.text :image_url
      t.boolean :featured, null: false, default: false    # aparece no banner de destaque
      t.date :release_date                                 # só para lançamentos
      t.references :user, null: true, foreign_key: { on_delete: :nullify } # admin que publicou

      t.timestamps
    end
    add_index :news_posts, [ :kind, :created_at ]

    # Registro de tudo que os administradores fazem (quem, o quê, em quem, quando).
    create_table :admin_actions do |t|
      t.references :admin, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :admin_name, null: false # guarda o nome mesmo se o admin for excluído
      t.string :action, null: false
      t.string :target_type
      t.bigint :target_id
      t.string :target_label
      t.text :details

      t.timestamps
    end
    add_index :admin_actions, :created_at

    add_column :users, :suspended_at, :datetime
    add_column :users, :suspended_reason, :string

    agora = Time.current
    NOTICIAS.each_with_index do |n, i|
      execute <<~SQL
        INSERT INTO news_posts (kind, category, title, summary, source_name, source_url, image_url, featured, release_date, created_at, updated_at)
        VALUES (#{q n[:kind]}, #{q n[:category]}, #{q n[:title]}, #{q n[:summary]}, #{q n[:source_name]}, #{q n[:source_url]},
                #{q n[:image_url]}, #{n[:featured] ? 'TRUE' : 'FALSE'}, #{q n[:release_date]}, #{q(agora - i.minutes)}, #{q(agora - i.minutes)})
      SQL
    end
  end

  def down
    remove_column :users, :suspended_reason
    remove_column :users, :suspended_at
    drop_table :admin_actions
    drop_table :news_posts
  end

  private

  def q(valor)
    connection.quote(valor)
  end
end
