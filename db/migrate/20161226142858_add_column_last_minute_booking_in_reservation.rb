class AddColumnLastMinuteBookingInReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :last_minute_booking, :boolean, default: false
  end
end
