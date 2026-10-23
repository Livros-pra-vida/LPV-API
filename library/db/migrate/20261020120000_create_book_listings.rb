class CreateBookListings < ActiveRecord::Migration[7.1]
  def change
    create_table :book_listings do |t|
      t.string :title
      t.string :author
      t.text :description
      t.decimal :price
      t.references :user, null: false, foreign_key: true
      t.string :image_url

      t.timestamps
    end
  end
end