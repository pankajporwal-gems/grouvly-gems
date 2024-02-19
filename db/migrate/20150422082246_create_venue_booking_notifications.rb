class CreateVenueBookingNotifications < ActiveRecord::Migration
  def change
    create_table :venue_booking_notifications do |t|
      t.belongs_to :venue_booking
      t.belongs_to :matched_reservation
      t.belongs_to :reservation
      t.string :slug
      t.boolean :acknowledged, default: false

      t.timestamps null: false
    end

    add_index :venue_booking_notifications, :venue_booking_id
    add_index :venue_booking_notifications, :matched_reservation_id
    add_index :venue_booking_notifications, :reservation_id
  end
end
