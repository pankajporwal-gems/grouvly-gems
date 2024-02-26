class UnmatchedReservationHistory < ApplicationRecord
  belongs_to :reservation
  belongs_to :user

  validates :schedule, presence: true
end
