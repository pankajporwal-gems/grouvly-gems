class DeleteColumnsInPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :data
    remove_column :payments, :name
    remove_column :payments, :street1
    remove_column :payments, :street2
    remove_column :payments, :city
    remove_column :payments, :state
    remove_column :payments, :country
    remove_column :payments, :zipcode
    remove_column :payments, :merchant_reference_code
    remove_column :payments, :card_vault_token
    remove_column :payments, :card_type
  end
end
