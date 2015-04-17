class AddTokensColumnToUsers < ActiveRecord::Migration
  def up
    add_column :users, :session_token, :string, default: ""
    add_column :users, :refresh_token, :string, default: ""
  end

  def down
    remove_column :users, :session_token
    remove_column :users, :refresh_token
  end
end
