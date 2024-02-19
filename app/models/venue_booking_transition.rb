class VenueBookingTransition < ActiveRecord::Base
  belongs_to :venue_booking, inverse_of: :venue_booking_transitions

  has_paper_trail
end
