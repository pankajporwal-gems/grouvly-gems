class Referral < ApplicationRecord
  belongs_to :user
  belongs_to :referrer, class_name: 'User', foreign_key: :user_id
  belongs_to :referral, class_name: 'User'

  has_paper_trail

  def self.referrer(user_id)
    referrer = self.where(referral_id: user_id).first
    referrer.user if referrer
  end
end
