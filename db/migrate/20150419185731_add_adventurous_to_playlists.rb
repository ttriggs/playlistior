class AddAdventurousToPlaylists < ActiveRecord::Migration
  def up
    add_column :playlists, :adventurous, :boolean, default: false
    add_column :playlists, :familiarity, :float, default: 0
    add_column :playlists, :tempo, :integer, default: 0
    add_column :playlists, :danceability, :float, default: 0
  end

  def down
    remove_column :playlists, :adventurous
    remove_column :playlists, :familiarity
    remove_column :playlists, :tempo
    remove_column :playlists, :danceability
  end
end
