class ChangeGroupsColToRgb < ActiveRecord::Migration
  def up
    rename_column :groups, :name, :rgb
  end
  def down
    rename_column :groups, :rgb, :name
  end
end
