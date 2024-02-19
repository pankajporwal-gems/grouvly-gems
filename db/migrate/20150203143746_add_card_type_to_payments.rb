class AddCardTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :card_type, :string
  end
end
