class NotSettledRefundWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    payment_processor = PaymentProcessor.new(reservation)
    errors_count = payment_processor.refund_partial_amount
    if errors_count != 0
      NotSettledRefundWorker.perform_at(1.day.from_now, reservation.id)
      obj = UserCache.get_not_settled_payment(reservation.id)
      count = obj.present? ? obj.to_i : 0
      count = count + 1
      UserCache.set_not_settled_payment(reservation.id, count)
    elsif errors_count == 0
      matched_res = reservation.matched_reservation || reservation.inverse_matched_reservation
      reservation.complete_match unless matched_res.current_state == "completed"
    end
  end
end