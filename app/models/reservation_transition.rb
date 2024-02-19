class ReservationTransition < ActiveRecord::Base
  belongs_to :reservation, inverse_of: :reservation_transitions

  has_paper_trail
end
