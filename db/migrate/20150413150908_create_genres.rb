class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string "name", null: false
      t.string "popularity", null: false
      t.string "category", null: false

      t.timestamps
    end
  end
end
