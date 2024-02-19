class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.belongs_to :user, null: false
      t.integer    :referral_id, null: false
      t.timestamps null: false
    end
  end
end
