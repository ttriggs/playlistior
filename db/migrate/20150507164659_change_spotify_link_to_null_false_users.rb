class ChangeSpotifyLinkToNullFalseUsers < ActiveRecord::Migration
  def up
    change_column :users, :spotify_link, :string, null: false
  end

  def down
    change_column :users, :spotify_link, :string
  end
end
