class CreateCartOrdersFavoritesAlerts < ActiveRecord::Migration[8.1]
  def change
    # Carrinho: o preço NÃO fica aqui, é sempre lido do catálogo (ninguém altera o preço pelo navegador).
    create_table :cart_items do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :catalog_book, null: false, foreign_key: { on_delete: :cascade }
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
    add_index :cart_items, [ :user_id, :catalog_book_id ], unique: true
    add_check_constraint :cart_items, "quantity BETWEEN 1 AND 20", name: "cart_items_quantity_range"

    # Pedidos: guardam uma "foto" dos itens e preços do momento da compra.
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :status, null: false, default: "Em separação"
      t.string :payment_method, null: false
      t.text :address, null: false # criptografado
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :shipping, precision: 10, scale: 2, null: false
      t.decimal :total, precision: 10, scale: 2, null: false

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: { on_delete: :cascade }
      t.references :catalog_book, null: true, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.text :image_url
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false

      t.timestamps
    end

    # Anúncios favoritos do Comprar & Trocar.
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :book_listing, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    add_index :favorites, [ :user_id, :book_listing_id ], unique: true

    # "Avise-me quando chegar": livros que o usuário está procurando.
    create_table :wish_alerts do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :term, null: false

      t.timestamps
    end
  end
end
