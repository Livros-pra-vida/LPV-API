class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :catalog_book, null: false, foreign_key: true
      t.integer :score, null: false

      t.timestamps
    end

    # Cada usuário avalia cada livro uma única vez (pode trocar a nota depois).
    add_index :ratings, [ :user_id, :catalog_book_id ], unique: true

    # Garantia no banco de que a nota fica entre 1 e 5, mesmo se alguém escrever direto na tabela.
    add_check_constraint :ratings, "score BETWEEN 1 AND 5", name: "ratings_score_between_1_and_5"
  end
end
