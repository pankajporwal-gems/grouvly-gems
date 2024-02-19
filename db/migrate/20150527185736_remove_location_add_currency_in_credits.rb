class RemoveLocationAddCurrencyInCredits < ActiveRecord::Migration
  def change
    remove_column :credits, :location
    add_column :credits, :currency, :string, null: false
  end
end
