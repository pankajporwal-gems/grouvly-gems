class AddVoucherIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :voucher_id, :integer
    add_index :payments, [:id, :voucher_id], unique: true
  end
end
