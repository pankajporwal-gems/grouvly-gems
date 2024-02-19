class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.belongs_to :user, null: false
      t.datetime :schedule, null: false
      t.timestamps null: false
    end
  end
end
