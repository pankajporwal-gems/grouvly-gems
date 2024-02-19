class CreateUnmatchedReservationHistories < ActiveRecord::Migration
  def change
    create_table :unmatched_reservation_histories do |t|
      t.references :reservation
      t.references :user
      t.datetime :schedule
      t.timestamps null: false
    end
  end
end
