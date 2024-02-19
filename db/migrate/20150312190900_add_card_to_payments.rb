class AddCardToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :card_id, :integer
    add_index :payments, :card_id
  end
end
