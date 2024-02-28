class Admin::MatchesController < Admin::AdminsController
  after_action -> { email_booked_venues(@bookings) }, only: :book_venues

  def index
    if params[:location]
      @presenter = ListMatchesPresenter.new({ location: params[:location] })
    else
      @presenter = ListMatchesPresenter.new
    end
  end

  def show
    @presenter = ShowMatchPresenter.new(location, schedule, matched_reservations)
  end

  def unmatch
    if matched_reservation.unmatch!(current_admin)
      flash[:notice] = t('admin.matches.show.unmatch_successfully')
    else
      flash[:error] = t('admin.matches.show.unmatch_wrongfully')
    end

    redirect_to :back
  end

  def confirm_match
    if matched_reservation.current_state == "completed"
      flash[:notice] = t('admin.matches.show.matched_successfully')
    else
      if matched_reservation.complete!(current_admin)
        flash[:notice] = t('admin.matches.show.confirm_match_successfully')
      else
        flash[:error] = t('admin.matches.show.confirm_match_wrongfully')
      end
    end
    redirect_to :back
  end

  def book_venues
    @bookings = []
    venue_booking_params.each do |reservation_id, venue_booking|
      if venue_booking[:venue].present? && venue_booking[:schedule].present?

        existing_booking = VenueBooking.active_bookings.where({matched_reservation_id: reservation_id}).first
        if existing_booking
          if existing_booking.venue_id != venue_booking[:venue].to_i || existing_booking.schedule != venue_booking[:schedule]
            existing_booking.cancel!
          else
            next
          end
        end

        @venue_booking = VenueBooking.new
        @venue_booking.matched_reservation_id = reservation_id
        @venue_booking.venue_id = venue_booking[:venue]
        @venue_booking.schedule = venue_booking[:schedule]
        if @venue_booking.save
          @venue_booking.new!
          @venue_booking.accept! # This is for portfolio setup
          @bookings << @venue_booking
        else
          flash[:error] = @venue_booking.errors.full_messages.first
        end

      end
    end

    if @bookings.any?
      flash[:notice] = t('admin.matches.show.book_venues_successfully', { count: @bookings.length })
    else
      flash[:error] = t('admin.matches.show.book_venues_wrongfully')
    end

    redirect_to :back
  end

  def notify_venue_location_details
    notifications = []

    matched_reservations.each do |matched_reservation|
      venue_booking = matched_reservation.latest_accepted_booking
      if venue_booking.present?
        [matched_reservation.first_reservation_id, matched_reservation.second_reservation_id].each do |reservation|

          existing_venue_notification = VenueBookingNotification
                                                  .where(venue_booking_id: venue_booking.id,
                                                         matched_reservation_id: matched_reservation.id,
                                                         reservation_id: reservation).first

          unless existing_venue_notification
            venue_booking_notification = VenueBookingNotification.new
            venue_booking_notification.venue_booking_id = venue_booking.id
            venue_booking_notification.matched_reservation_id = matched_reservation.id
            venue_booking_notification.reservation_id = reservation

            if venue_booking_notification.save
              SendVenueLocationDetailsJob.perform_now(venue_booking_notification.id)
              notifications << venue_booking_notification
            end
          end

        end
      end
    end

    if notifications.any?
      flash[:notice] = t('admin.matches.show.send_location_details_successfully', { count: notifications.length/2 })
    else
      flash[:error] = t('admin.matches.show.send_location_details_wrongfully')
    end

    redirect_to :back
  end

  private

  def location
    params[:id] || params[:location]
  end

  def schedule
    params[:date]
  end

  def matched_reservations
    @matched_reservations ||= MatchedReservation.in_state(:new, :completed).find_by_location(location).find_by_schedule(schedule).page(params[:page])
  end

  def matched_reservation
    MatchedReservation.find(params[:id])
  end

  def venue_booking_params
    params.require(:venue_booking)
  end

  def email_booked_venues(bookings)
    if bookings.any?
      # Group multiple bookings for the same venue into a single email
      venues = bookings.collect { |booking| booking.venue_id }.uniq
      venues.each do |venue|
        venue_bookings = bookings.select { |booking| booking.venue_id == venue }
        SendVenueTableBookingJob.perform_now(venue, venue_bookings)
      end
    end
  end
end
