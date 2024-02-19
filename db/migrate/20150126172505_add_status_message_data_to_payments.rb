class AddStatusMessageDataToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :currency, :string, null: false
    add_column :payments, :status, :string
    add_column :payments, :message, :string
    add_column :payments, :data, :json
  end
end
