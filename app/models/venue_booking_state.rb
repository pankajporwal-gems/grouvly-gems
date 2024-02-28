class VenueBookingState
  def initialize(venue_booking)
    @venue_booking ||= venue_booking
  end
  
  def pending?
    @venue_booking.current_state == 'pending'
  end
  
  def accepted?
    @venue_booking.current_state == 'accepted'
  end
  
  def rejected?
    @venue_booking.current_state == 'rejected'
  end
  
  def cancelled
    @venue_booking.current_state == 'cancelled'
  end

  def new!
    @venue_booking.transition_to(:pending, { occured_on: Time.now }.to_json)
  end
  
  def accept!
    @venue_booking.transition_to(:accepted, { occured_on: Time.now }.to_json)
  end
  
  def reject!
    @venue_booking.transition_to(:rejected, { occured_on: Time.now }.to_json)
  end
  
  def cancel!
    @venue_booking.transition_to(:cancelled, { occured_on: Time.now }.to_json)
  end
end
