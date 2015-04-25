class AddJsonCachesToPlaylists < ActiveRecord::Migration
  def up
    add_column :playlists, :energy_json_cache, :text
    add_column :playlists, :liveness_json_cache, :text
    add_column :playlists, :tempo_json_cache, :text
    add_column :playlists, :danceability_json_cache, :text
  end

  def down
    remove_column :playlists, :energy_json_cache
    remove_column :playlists, :liveness_json_cache
    remove_column :playlists, :tempo_json_cache
    remove_column :playlists, :danceability_json_cache
  end
end
