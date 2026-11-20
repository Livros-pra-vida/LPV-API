class AddProfileAndEncryptionToUsers < ActiveRecord::Migration[8.1]
  # Endereço, pagamento e foto passam do navegador para o banco.
  # CPF e telefone viram "text" porque o valor criptografado é bem maior que o original.
  def up
    change_column :users, :cpf, :text
    change_column :users, :telefone, :text

    add_column :users, :cep, :text
    add_column :users, :rua, :text
    add_column :users, :numero, :text
    add_column :users, :bairro, :text
    add_column :users, :cidade, :text
    add_column :users, :pagamento_favorito, :string
    add_column :users, :avatar_url, :text

    change_column_default :users, :admin, from: nil, to: false
    execute "UPDATE users SET admin = FALSE WHERE admin IS NULL"
    change_column_null :users, :admin, false

    # E-mail único também no banco (sem diferenciar maiúsculas), além da validação do model.
    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_lower_email"
  end

  def down
    remove_index :users, name: "index_users_on_lower_email"
    change_column_null :users, :admin, true
    change_column_default :users, :admin, from: false, to: nil
    remove_column :users, :avatar_url
    remove_column :users, :pagamento_favorito
    remove_column :users, :cidade
    remove_column :users, :bairro
    remove_column :users, :numero
    remove_column :users, :rua
    remove_column :users, :cep
    change_column :users, :telefone, :string
    change_column :users, :cpf, :string
  end
end
