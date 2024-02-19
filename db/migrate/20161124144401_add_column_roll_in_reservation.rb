class AddColumnRollInReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :is_roll, :boolean, default: false
  end
end
