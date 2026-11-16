class CreateCatalogBooks < ActiveRecord::Migration[8.1]
  def change
    # Livros do Catálogo da loja (os que recebem avaliação pública).
    # São diferentes de "books", que são os livros das estantes privadas de cada usuário.
    create_table :catalog_books do |t|
      t.string :title, null: false
      t.string :author_name, null: false

      t.timestamps
    end

    add_index :catalog_books, "lower(title)", unique: true, name: "index_catalog_books_on_lower_title"
  end
end
