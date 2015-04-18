class RemoveTastesFromPlaylists < ActiveRecord::Migration
  def up
    remove_column :playlists, :taste_id
    remove_column :playlists, :taste_ticket
  end

  def down
    add_column :playlists, :taste_id, :string, default: ""
    add_column :playlists, :taste_ticket, :string, default: ""
  end
end
