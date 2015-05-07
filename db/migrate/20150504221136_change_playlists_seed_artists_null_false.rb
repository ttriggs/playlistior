class ChangePlaylistsSeedArtistsNullFalse < ActiveRecord::Migration
  def up
    change_column :playlists, :seed_artist, :string, null: false
  end

  def down
    change_column :playlists, :seed_artist, :string
  end
end
