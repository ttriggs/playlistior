class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.integer :group_id,   null: false
      t.string :name,       null: false
      t.string :popularity, null: false

      t.timestamps
    end
  end
end
