class AddAddressMerchantReferenceCodeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :name, :string
    add_column :payments, :street1, :string
    add_column :payments, :street2, :string
    add_column :payments, :city, :string
    add_column :payments, :state, :string
    add_column :payments, :country, :string
    add_column :payments, :zipcode, :string
    add_column :payments, :merchant_reference_code, :string
    add_column :payments, :card_vault_token, :string
  end
end
