class ReservationTransition < ApplicationRecord
  belongs_to :reservation, inverse_of: :reservation_transitions

  has_paper_trail
end
