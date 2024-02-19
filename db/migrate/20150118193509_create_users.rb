class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :oauth_token, null: false
      t.datetime :oauth_expires_at, null: false

      t.timestamps null: false
    end

    add_index :users, :provider
    add_index :users, :uid
  end
end
