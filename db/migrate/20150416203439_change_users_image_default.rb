class ChangeUsersImageDefault < ActiveRecord::Migration
  def up
    change_column :users, :image, :string, default: nil
  end

  def down
    change_column :users, :image, :string, default: ""
  end
end
