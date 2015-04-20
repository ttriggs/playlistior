class ChangeGenresGroupIdDefault < ActiveRecord::Migration
  def up
    change_column :genres, :group_id, :integer, default: 16
  end

  def down
    change_column :genres, :group_id, :integer, null: false
  end
end
