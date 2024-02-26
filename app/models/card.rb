class Card < ApplicationRecord
  belongs_to :user
  has_many :payments
  has_many :refunds

  validates :token, :bin, :card_type, :last_digits, presence: true

  has_paper_trail
end
