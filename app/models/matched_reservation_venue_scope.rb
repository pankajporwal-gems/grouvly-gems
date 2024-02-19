class MatchedReservationVenueScope
  def initialize(matched_reservation)
    @matched_reservation ||= matched_reservation
  end

  def latest_booking
    VenueBooking
      .not_in_state(:cancelled)
      .where(matched_reservation_id: @matched_reservation.id )
      .first
  end

  def latest_accepted_booking
    VenueBooking
      .in_state(:accepted)
      .where(matched_reservation_id: @matched_reservation.id )
      .first
  end
end