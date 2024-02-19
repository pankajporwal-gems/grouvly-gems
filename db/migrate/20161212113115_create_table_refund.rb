class CreateTableRefund < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.belongs_to  :reservation
      t.belongs_to  :payment
      t.belongs_to  :card
      t.decimal :amount
      t.string :currency
      t.string :status
      t.text :messages
      t.string :transaction_id
      t.timestamps
    end
  end
end
