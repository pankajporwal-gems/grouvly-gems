class AddScheduleInMatchedReservations < ActiveRecord::Migration
  def change
    add_column :matched_reservations, :schedule, :datetime
  end
end
