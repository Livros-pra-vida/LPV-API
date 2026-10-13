class AddDadosPessoaisToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :telefone, :string
    add_column :users, :cpf, :string
    add_column :users, :nascimento, :date
  end
end
