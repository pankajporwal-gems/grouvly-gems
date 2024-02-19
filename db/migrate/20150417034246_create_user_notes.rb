class CreateUserNotes < ActiveRecord::Migration
  def change
    create_table :user_notes do |t|
      t.belongs_to  :user
      t.text        :content, null: false
      t.timestamps null: false
    end

    add_index :user_notes, :user_id
  end
end
