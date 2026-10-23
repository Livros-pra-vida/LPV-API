class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title
      t.integer :rating
      t.references :bookcase, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.date :release

      t.timestamps
    end
  end
end
