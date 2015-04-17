class RemoveTokenFromPlaylists < ActiveRecord::Migration
  def up
    remove_column :playlists, :create_token
  end

  def down
    add_column :playlists, :create_token, :string, default: ""
  end
end
