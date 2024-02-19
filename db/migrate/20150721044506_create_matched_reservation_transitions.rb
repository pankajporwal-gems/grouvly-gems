class CreateMatchedReservationTransitions < ActiveRecord::Migration
  def change
    create_table :matched_reservation_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :matched_reservation_id, null: false
      t.timestamps
    end

    add_index :matched_reservation_transitions, :matched_reservation_id
    add_index :matched_reservation_transitions, [:sort_key, :matched_reservation_id], name: 'by_sort_key_and_matched_reservation_id', unique: true
  end
end
