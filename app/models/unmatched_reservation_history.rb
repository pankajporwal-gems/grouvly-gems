class UnmatchedReservationHistory < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :user

  validates :schedule, presence: true
end
