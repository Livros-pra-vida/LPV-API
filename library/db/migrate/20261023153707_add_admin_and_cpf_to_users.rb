class AddAdminAndCpfToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean, default: false unless column_exists?(:users, :admin)
    add_column :users, :cpf, :string unless column_exists?(:users, :cpf)
  end
end