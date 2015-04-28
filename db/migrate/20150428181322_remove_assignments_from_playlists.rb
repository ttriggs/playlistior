class RemoveAssignmentsFromPlaylists < ActiveRecord::Migration
  def up
    remove_column :playlists, :assignment_id
  end

  def down
    add_column :playlists, :assignment_id, :integer
  end
end
