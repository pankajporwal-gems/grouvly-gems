class UnmatchedEmailWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options queue: 'mailers'

  recurrence {weekly.day(:thursday).hour_of_day(16)}

  # recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)}

  def perform
    date = Chronic.parse('today at 8PM')
    # date = "2016-12-22 20:00:00"
    reservations = Reservation.unmatched.find_by_schedule(date)
    reservations.find_each do |reservation|
      if UserCache.get_unmatched_email_send(reservation.id, date).blank? && !reservation.refund.present?
        user = reservation.user

        if user.blank?
          SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: user not found for reservation: #{reservation.id}"
          next
        end

        re_history = reservation.unmatched_reservation_histories.build(user_id: reservation.user_id, schedule: date)

        if re_history.save
          SIDEKIQ_LOGGER.info "UnmatchedEmailWorker: re_history created with re_history_id: #{re_history.id}, reservation.user_id: #{reservation.user_id}, schedule_date: #{date}"
        else
          SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: error in creating re_history for reservation.user_id: #{reservation.user_id}, schedule_date: #{date}, errors: #{re_history.errors}"
        end

        if reservation.is_roll?
          SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: found is_roll true for reservation_id: #{reservation.id} user: #{user.id}"

          schedule_date = Grouvly::ReservationDate.available_valid_dates(user)
          if schedule_date.present?
            SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: updating schedule_date for reservation_id: #{reservation.id}, from #{reservation.schedule} to #{schedule_date.first}"

            reservation_updated = reservation.update_attributes(schedule: schedule_date.first)
            SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: updated reservation_id: #{reservation.id} : #{reservation_updated}, errors: #{reservation.errors}"
          else
            SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: next schedule_date not found for user: #{user.id}, reservation_id: #{reservation.id}"
          end
        else
          if user.email_address.present?
            ReservationMailer.notify_about_unmatched_reservation(user, reservation.slug).deliver
            UserCache.set_unmatched_email_send(reservation.id, date)
            SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: sent email for user_id: #{user.id}"
          else
            SIDEKIQ_LOGGER.info "UnmatchedEmailWorker:: email not found for user_id: #{user.id}"
          end
        end
      end
    end
  end

end