class AddWingQuantityInReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :wing_quantity, :integer, default: 2
  end
end
