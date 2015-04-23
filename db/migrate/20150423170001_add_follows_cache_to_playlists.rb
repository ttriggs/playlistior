class AddFollowsCacheToPlaylists < ActiveRecord::Migration
  def up
    add_column :playlists, :follows_cache, :integer, default: 0
  end

  def down
    remove_column :playlists, :follows_cache
  end
end
