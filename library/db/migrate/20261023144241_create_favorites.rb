class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book_listing, null: false, foreign_key: true

      t.timestamps
    end
  end
end
