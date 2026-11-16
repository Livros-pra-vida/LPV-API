class AddUserToBookcases < ActiveRecord::Migration[8.1]
  def change
    # Cada estante passa a ter um dono. A coluna aceita NULL só para não quebrar
    # as estantes antigas que já existem no banco: como todas as consultas
    # filtram por usuário, uma estante sem dono simplesmente não aparece para ninguém.
    add_reference :bookcases, :user, null: true, foreign_key: true

    # Limite padrão para estantes criadas sem informar o limite
    change_column_default :bookcases, :limit, from: nil, to: 50
  end
end
