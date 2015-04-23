class AddUriArrayToPlaylists < ActiveRecord::Migration
  def up
    add_column :playlists, :uri_array, :text, default: "[]"
  end

  def down
    remove_column :playlists, :uri_array
  end
end
