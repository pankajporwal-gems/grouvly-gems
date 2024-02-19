class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.belongs_to  :user
      t.string      :token, null: false
      t.integer     :bin, null: false
      t.string      :card_type, null: false
      t.integer     :customer_id, null: false
      t.integer     :last_digits, null: false
      t.timestamps null: false
    end
  end
end
