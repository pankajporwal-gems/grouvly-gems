class MatchedReservationTransition < ActiveRecord::Base
  belongs_to :matched_reservation, inverse_of: :matched_reservation_transitions

  has_paper_trail
end
