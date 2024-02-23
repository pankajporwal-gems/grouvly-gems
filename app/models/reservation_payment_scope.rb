class ReservationPaymentScope
  def initialize(reservation)
    @reservation = reservation
  end

  def is_full?
    @reservation.payments.successful.count == wing_quantity.to_i + 1
  end

  def pending_payments
    pending_payments = Payment.pending_payments(@reservation)
  end

  def all_valid_payments
    @all_valid_payments ||= Payment.all_valid_payments(@reservation)
  end

  def all_due_payments
    all_due_payments ||= Payment.all_due_payments_for_reservation(@reservation)
  end

  def wing_quantity
    @reservation.wing_quantity
  end

  def lead
    @reservation.user
  end

  def wings
    @reservation.payments.includes(card: :user).joins('LEFT JOIN cards ON cards.id = payments.card_id')
      .joins('LEFT JOIN reservations ON reservations.id = payments.reservation_id')
      .where("(payments.status = 'success' AND payments.method = 'authorize') OR (payments.method = 'capture')")
      .where('reservations.user_id != cards.user_id').map { |payment| payment.card.user }
  end

  def available_members
    [lead] + wings
  end

  def recently_booked?
    first_payment = all_valid_payments.first
    first_payment.created_at + 10.seconds >= first_payment.updated_at && first_payment.updated_at + 3.seconds >= Chronic.parse('now')
  end

  def total_amount_paid
    @reservation.payments.successful.captured.sum(:amount)
  end
end
