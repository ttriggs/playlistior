class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    t.string   "username",                 null: false
    t.string   "email", default: "",       null: false
    t.string   "role", default: "user"
    t.string   "profile_photo",            default: ""

    t.timestamps
  end
  add_index :users, :username,             unique: true
  add_index :users, :email,                unique: true
end
