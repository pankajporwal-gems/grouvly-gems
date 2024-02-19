class AddStateToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :method, :string, default: 'authorize'
  end
end
