class RemoveCountryColumnFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :country
  end

  def down
    add_column :users, :country, :string
  end
end
