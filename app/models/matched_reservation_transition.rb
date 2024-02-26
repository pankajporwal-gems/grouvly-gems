class MatchedReservationTransition < ApplicationRecord
  belongs_to :matched_reservation, inverse_of: :matched_reservation_transitions

  has_paper_trail
end
