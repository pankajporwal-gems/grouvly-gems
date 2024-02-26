class ReservationState
  def initialize(reservation)
    @reservation = reservation
  end

  def new?
    @reservation.current_state == 'new'
  end

  def cancelled?
    @reservation.current_state == 'cancelled'
  end

  def payment_entered?
    @reservation.current_state == 'payment_entered'
  end

  def pending_payment?
    @reservation.current_state == 'pending_payment'
  end

  def new!
    @reservation.transition_to(:new, { occured_on: Time.now })
  end

  def cancel!(performer = nil, reason = nil)
    @reservation.transition_to(:cancelled, { occured_on: Time.now, performed_by: performer, reason: reason })
  end

  def enter_payment!
    @reservation.transition_to(:payment_entered, { occured_on: Time.now }.to_json)
  end

  def pending_peyment!
    @reservation.transition_to(:pending_payment, { occured_on: Time.now })
  end
end
