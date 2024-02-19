class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :reservation, null: false
      t.belongs_to :user, null: false
      t.float :amount, null: false

      t.timestamps null: false
    end
  end
end
