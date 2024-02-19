class AddColumnUpdatedByInReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :updated_by, :string
  end
end
