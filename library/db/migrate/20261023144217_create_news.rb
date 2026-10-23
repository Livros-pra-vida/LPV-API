class CreateNews < ActiveRecord::Migration[8.1]
  def change
    create_table :news do |t|
      t.string :title
      t.string :source
      t.text :description
      t.string :image_url
      t.string :category

      t.timestamps
    end
  end
end
