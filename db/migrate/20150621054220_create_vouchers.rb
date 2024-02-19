class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :description, null: false
      t.string :voucher_type, null: false
      t.date :start_date
      t.date :end_date
      t.integer :quantity
      t.string :gender
      t.integer :user_id
      t.string :restriction
      t.timestamps null: false
    end
  end
end
