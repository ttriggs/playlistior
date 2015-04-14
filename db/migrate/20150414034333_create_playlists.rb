class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string   :name,       null: false
      t.integer  :user_id,    null: false
      t.string   :spotify_id, null: false
      t.string   :link,       null: false
      t.string   :seed_artist
      t.string   :create_token, default: ""

      t.timestamps
    end
  end
end
