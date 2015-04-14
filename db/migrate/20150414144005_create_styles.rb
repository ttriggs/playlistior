class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.integer :playlist_id, null: false
      t.integer :genre_id, null: false

      t.timestamps
    end
    add_index :styles, [:genre_id, :playlist_id], :unique => true
  end
end
