class ChangeGenresPopularityDefault < ActiveRecord::Migration
  def up
    change_column :genres, :popularity, :string, default: "20"
  end

  def down
    change_column :genres, :popularity, :string, null: false
  end
end
