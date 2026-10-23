class AddAddressToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :cep, :string
    add_column :users, :rua, :string
    add_column :users, :numero, :string
    add_column :users, :bairro, :string
    add_column :users, :cidade, :string
    add_column :users, :pagamento_favorito, :string
  end
end