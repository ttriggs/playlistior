class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   "name",                      null: false
      t.string   "email",        default: ""
      t.string   "spotify_id",                null: false
      t.string   "spotify_link", default: ""
      t.string   "image",        default: ""
      t.string   "country",      default: ""
      t.string   "role",         default: "user"

      t.timestamps
    end
    add_index :users, :spotify_id,  unique: true
  end
end
