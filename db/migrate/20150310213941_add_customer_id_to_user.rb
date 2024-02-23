class AddCustomerIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :customer_id, :string
    remove_column :cards, :customer_id

    add_index :users, :customer_id, unique: true
  end
end
