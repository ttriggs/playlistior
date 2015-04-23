class RemoveGroupIdColFromTracks < ActiveRecord::Migration
  def up
    remove_column :tracks, :group_id
  end

  def down
    add_column :tracks, :group_id, :integer, null: false
  end
end
