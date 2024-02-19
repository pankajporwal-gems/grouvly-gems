class AddMissingIndeces < ActiveRecord::Migration
  def change
    add_index :cards, :user_id
    add_index :credits, :user_id
    add_index :matched_reservations, :first_reservation_id
    add_index :matched_reservations, :second_reservation_id
    add_index :payments, :reservation_id
    add_index :referrals, :user_id
    add_index :referrals, :referral_id
    add_index :reservations, :user_id
    add_index :vouchers, :user_id
  end
end
