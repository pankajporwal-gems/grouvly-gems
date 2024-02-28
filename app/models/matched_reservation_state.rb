class MatchedReservationState
  def initialize(matched_reservation)
    @matched_reservation = matched_reservation
  end

  def new?
    @matched_reservation.current_state == 'new'
  end

  def unmatched?
    @matched_reservation.current_state == 'unmatched'
  end

  def completed?
    @matched_reservation.current_state == 'completed'
  end

  def new!(performer = nil)
    @matched_reservation.transition_to(:new, { occured_on: Time.now, performed_by: performer }.to_json)
  end

  def unmatch!(performer = nil)
    @matched_reservation.transition_to(:unmatched, { occured_on: Time.now, performed_by: performer }.to_json)
  end

  def complete!(performer = nil)
    @matched_reservation.transition_to(:completed, { occured_on: Time.now, performed_by: performer }.to_json)
  end
end
