class RemoveSpotifyIdFromPlaylists < ActiveRecord::Migration
  def up
    remove_column :playlists, :spotify_id
  end

  def down
    add_column :playlists, :spotify_id, :string
  end
end
