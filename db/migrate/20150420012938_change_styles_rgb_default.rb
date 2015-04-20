class ChangeStylesRgbDefault < ActiveRecord::Migration
  def up
    change_column :groups, :rgb, :string, default: "(100, 100, 100)"
  end

  def down
    change_column :groups, :rgb, :string, null: false
  end
end
