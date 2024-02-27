namespace :reservation do
  desc 'CRON job to send email reminders for the first reservation'
  task send_first_reservation_reminder_email: :environment do
    users = User.users_accepted_yesterday_and_not_booked

    users.each do |user|
      SendFirstReservationReminderJob.perform_now(user.id)
    end
  end

  desc 'CRON job to track user who successfully went on a Grouvly'
  task track_event_completed_grouvly: :environment do
    # Get all reservation between 7pm and 10pm which is the booking window
    matched_reservations = MatchedReservation.in_state(:new).find_by_schedule(Chronic.parse('today at 7pm')..Chronic.parse('today at 10pm'))

    matched_reservations.each do |matched_reservation|
      [:first_reservation, :second_reservation].each do |index|
        reservation = matched_reservation.send(index)
        Grouvly::SegmentTracking::track_event(reservation.user, Grouvly::SegmentTracking::EVENT_GROUVLY_COMPLETED)
      end
    end

    # TODO: Grouvly::SegmentTracking::flush does not work as it should
    sleep(1)
  end

  desc 'CRON job to update payments of recent grouvlies'
  task update_payments: :environment do
    recent_date = Grouvly::ReservationDate.all_available_dates_with_most_recent.first.last
    next_date = Grouvly::ReservationDate.all_available_dates_with_most_recent[1].last

    [recent_date, next_date].each do |day|
      matched_reservations = MatchedReservation.find_by_schedule(day)

      matched_reservations.each do |matched_reservation|
        [:first_reservation, :second_reservation].each do |index|
          reservation = matched_reservation.send(index)
          payment_processor = PaymentProcessor.new(reservation)
          payment_processor.update_payments
        end
      end
    end
  end

  task update_state: :environment do
    PaperTrail::Version.where(item_type: "MatchedReservation", event: "destroy").each do |data|
      begin
        data = data.reify
        data.save(validate: false)
        data.unmatch!
      rescue
      end
    end

    MatchedReservation.not_in_state(:unmatched).each do |matched_reservation|
      if (matched_reservation.first_reservation.all_due_payments.blank? &&
        matched_reservation.second_reservation.all_due_payments.blank?)

        matched_reservation.complete!
        matched_reservation.update(schedule: matched_reservation.first_reservation.schedule)
      end

      matched_reservation.update(schedule: matched_reservation.first_reservation.schedule)
    end

    PaperTrail::Version.where(item_type: "Reservation", event: "destroy").each do |data|
      begin
        data = data.reify
        data.save(validate: false)
        data.enter_payment!
        data.cancel!
      rescue
      end
    end

    Reservation.not_in_state(:cancelled).each do |reservation|
      reservation.enter_payment! if reservation.all_valid_payments.any?
    end
  end

  desc 'CRON job to update old payment methods'
  task update_old_payment_methods: :environment do
    Payment.find_each do |payment|
      reservation = payment.reservation
      if reservation.present?
        user = reservation.user
        if user.present? && user.location.present? && user.gender.present?
          payment.amount = (APP_CONFIG['fee'][user.location][user.gender])
          payment.save(validate: false)
        end
      end
    end
  end


end
