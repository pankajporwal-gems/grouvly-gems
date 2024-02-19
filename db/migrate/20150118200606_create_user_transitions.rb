class CreateUserTransitions < ActiveRecord::Migration
  def change
    create_table :user_transitions do |t|
      t.string  :to_state
      t.json    :metadata, default: "{}"
      t.integer :sort_key
      t.integer :user_id
      t.timestamps
    end

    add_index :user_transitions, :user_id
    add_index :user_transitions, [:sort_key, :user_id], unique: true
  end
end
