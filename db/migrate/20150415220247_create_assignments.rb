class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :track_id, null: false
      t.integer :playlist_id, null: false

      t.timestamps
    end
    add_index :assignments, [:track_id, :playlist_id], :unique => true
  end
end
