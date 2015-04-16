class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.integer :group_id,    null: false
      t.string  :artist_name, null: false
      t.string  :echonest_id, null: false
      t.string  :spotify_id,  null: false
      t.string  :title,       null:false
      t.integer :key
      t.integer :mode
      t.float   :energy
      t.float   :liveness
      t.float   :tempo
      t.integer :time_signature
      t.float   :danceability

      t.timestamps
    end

  end
end
