class AddAmountToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :amount, :float, null: false
  end
end
