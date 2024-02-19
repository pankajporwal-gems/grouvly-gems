class RefundAmountWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence {weekly.day(:thursday).hour_of_day(21)}

  # recurrence { hourly.minute_of_hour(0, 10, 20, 30, 35, 40, 50, 55)}
  def perform
    date = Chronic.parse('today at 8PM')
    reservations = Reservation.matched.find_by_schedule(date)
    reservations.each do |reservation|
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
end