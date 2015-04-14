class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.integer :playlist_id, null: false
      t.string :uri, null: false

      t.timestamps
    end
  end
end
