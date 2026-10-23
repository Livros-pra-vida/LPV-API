class AddDetailsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :genre, :string unless column_exists?(:books, :genre)
    add_column :books, :price, :decimal unless column_exists?(:books, :price)
    add_column :books, :rating, :float unless column_exists?(:books, :rating)
    add_column :books, :image_url, :string unless column_exists?(:books, :image_url)
    add_column :books, :description, :text unless column_exists?(:books, :description)
  end
end