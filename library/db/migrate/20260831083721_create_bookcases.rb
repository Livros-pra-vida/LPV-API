class CreateBookcases < ActiveRecord::Migration[8.1]
  def change
    create_table :bookcases do |t|
      t.integer :limit
      
      t.timestamps
    end
  end
end
