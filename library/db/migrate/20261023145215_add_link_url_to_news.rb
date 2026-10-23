class AddLinkUrlToNews < ActiveRecord::Migration[8.1]
  def change
    add_column :news, :link_url, :string
  end
end
