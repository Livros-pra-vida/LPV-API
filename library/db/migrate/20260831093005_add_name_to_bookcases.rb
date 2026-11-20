class AddNameToBookcases < ActiveRecord::Migration[8.1]
  def change
    add_column :bookcases, :name, :string
  end
end
