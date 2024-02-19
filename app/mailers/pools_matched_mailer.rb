class PoolsMatchedMailer < BaseMailer
  def send_table_booking_to_venues(venue, venue_bookings)
    @venue_bookings = venue_bookings
    @venue_bookings_slugs = venue_bookings.collect { |booking| booking.slug }
    @is_multiple_table_booking = venue_bookings.length > 1
    @venue_booking_mailer_presenter = VenueBookingMailerPresenter.new(venue_bookings[0])

    @user = venue

    set_concierge_details

    booking_date_time = @venue_booking_mailer_presenter.booking_date + ' ' +  @venue_booking_mailer_presenter.booking_time
    girl_name = @venue_booking_mailer_presenter.first_reservation_name
    guy_name = @venue_booking_mailer_presenter.second_reservation_name

    mail(to: venue.manager_email, subject: t('mailers.pools_matched.table_booking.subject',
      booking_date: booking_date_time, participents_count: @venue_booking_mailer_presenter.participents_count, girl_name: girl_name, guy_name: guy_name ))
  end

  def send_venue_location_details(venue_booking_notification)
    @venue_notification_mailer_presenter = VenueNotificationMailerPresenter.new(venue_booking_notification)

    set_concierge_details

    subject = if @venue_notification_mailer_presenter.schedule_has_changed?
      t('mailers.pools_matched.notification_venue_schedule_changed.subject',
        booking_day: @venue_notification_mailer_presenter.booking_day,
        booking_time: @venue_notification_mailer_presenter.booking_time)
    else
      t('mailers.pools_matched.notification_venue.subject',
        booking_day: @venue_notification_mailer_presenter.booking_day,
        booking_time: @venue_notification_mailer_presenter.booking_time)
    end

    mail(to: venue_booking_notification.notification_email, subject: subject)
  end
end
