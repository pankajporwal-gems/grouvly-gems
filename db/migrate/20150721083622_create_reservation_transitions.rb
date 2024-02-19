class CreateReservationTransitions < ActiveRecord::Migration
  def change
    create_table :reservation_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :reservation_id, null: false
      t.timestamps
    end

    add_index :reservation_transitions, :reservation_id
    add_index :reservation_transitions, [:sort_key, :reservation_id], unique: true
  end
end
