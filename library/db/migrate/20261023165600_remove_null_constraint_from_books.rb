class RemoveNullConstraintFromBooks < ActiveRecord::Migration[8.0]
  def change
    change_column_null :books, :bookcase_id, true if column_exists?(:books, :bookcase_id)
    change_column_null :books, :author_id, true if column_exists?(:books, :author_id)
  end
end