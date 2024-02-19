class CreateVenueBookingTransitions < ActiveRecord::Migration
  def change
    create_table :venue_booking_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :venue_booking_id, null: false
      t.timestamps
    end

    add_index :venue_booking_transitions, :venue_booking_id
    add_index :venue_booking_transitions, [:sort_key, :venue_booking_id], unique: true, name: 'index_venue_booking_transitions_'
  end
end
