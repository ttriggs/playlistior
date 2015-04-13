class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   "name",                      null: false
      t.string   "email",        default: "", null: false
      t.string   "spotify_id",                null: false
      t.string   "role",         default: "user"
      t.string   "image",        default: ""
      t.string   "country",      default: ""
      t.string   "spotify_link", default: ""

      t.timestamps
    end
    add_index :users, :name,  unique: true
    add_index :users, :email, unique: true
  end
end
