class CreateVenueBookings < ActiveRecord::Migration
  def change
    create_table :venue_bookings do |t|
      t.belongs_to  :venue, null: false
      t.belongs_to  :matched_reservation, null: false
      t.datetime    :schedule, null: false
      t.string      :slug

      t.timestamps null: false
    end

    add_foreign_key :venue_bookings, :venues
    add_foreign_key :venue_bookings, :matched_reservations
    add_index :venue_bookings, :venue_id
    add_index :venue_bookings, :matched_reservation_id
    add_index :venue_bookings, :slug
  end
end
