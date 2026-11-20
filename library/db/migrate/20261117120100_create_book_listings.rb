class CreateBookListings < ActiveRecord::Migration[8.1]
  def change
    # Anúncios da página Comprar & Trocar (antes ficavam só no localStorage de cada navegador).
    create_table :book_listings do |t|
      t.string :title, null: false
      t.string :author_name, null: false
      t.string :modality, null: false             # "Venda", "Troca" ou "Doação"
      t.decimal :price, precision: 10, scale: 2   # só para Venda
      t.string :region
      t.string :status, null: false, default: "Disponivel"
      t.text :image_url
      t.string :reputation, null: false, default: "5.0 (1 troca)"
      # Dono do anúncio. Nulo nos anúncios de exemplo, que mostram só o nome em seller_name.
      t.references :user, null: true, foreign_key: true
      t.string :seller_name

      t.timestamps
    end
  end
end
