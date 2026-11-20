class CreateConversationsAndPrivateMessages < ActiveRecord::Migration[8.1]
  def change
    # Conversa privada de negociação: um comprador fala com o anunciante sobre um anúncio.
    create_table :conversations do |t|
      t.references :book_listing, null: true, foreign_key: { on_delete: :nullify }
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.string :listing_title, null: false # guarda o título mesmo se o anúncio for apagado
      t.datetime :last_message_at

      t.timestamps
    end
    # Uma conversa por comprador e anúncio.
    add_index :conversations, [ :book_listing_id, :buyer_id ], unique: true

    # Mensagens privadas: o texto fica CRIPTOGRAFADO no banco.
    create_table :private_messages do |t|
      t.references :conversation, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end
    add_index :private_messages, [ :conversation_id, :created_at ]
  end
end
