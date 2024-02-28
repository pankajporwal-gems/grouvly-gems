class VenueBookingTransition < ApplicationRecord
  belongs_to :venue_booking, inverse_of: :venue_booking_transitions

  has_paper_trail

  def sort_key
    super.to_i
  end
end
