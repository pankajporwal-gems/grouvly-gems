class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.references :user
      t.float :amount, default: 0
      t.string :action
      t.string :activity
      t.integer :actor_id, null: false
      t.string :location
      t.timestamps null: false
    end
  end
end
