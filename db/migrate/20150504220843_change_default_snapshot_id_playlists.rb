class ChangeDefaultSnapshotIdPlaylists < ActiveRecord::Migration
  def up
    change_column :playlists, :snapshot_id, :string, null: false
  end

  def down
    change_column :playlists, :snapshot_id, :string
  end
end
