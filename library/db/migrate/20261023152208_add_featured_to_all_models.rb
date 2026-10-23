class AddFeaturedToAllModels < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :featured, :boolean, default: false unless column_exists?(:books, :featured)
    add_column :book_listings, :featured, :boolean, default: false unless column_exists?(:book_listings, :featured)
    add_column :news, :featured, :boolean, default: false unless column_exists?(:news, :featured)
  end
end