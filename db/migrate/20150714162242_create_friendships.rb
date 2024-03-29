class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.belongs_to :user, null: false
      t.integer :friend_id, null: false
      t.timestamps null: false
    end

    add_index :friendships, :user_id
    add_index :friendships, :friend_id
  end
end
