class ChangeMessagesContentToText < ActiveRecord::Migration[8.1]
  # O texto do chat global passa a ser gravado criptografado (fica maior que 255 caracteres).
  def up
    change_column :messages, :content, :text
  end

  def down
    change_column :messages, :content, :string
  end
end
