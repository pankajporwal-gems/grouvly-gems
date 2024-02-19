class VenueBookingDecorator
  def initialize(venue_booking)
    @venue_booking ||= venue_booking
  end

  def schedule
    @venue_booking.schedule
  end

  def participents_count
    matched_reservation_decorator.total_participents_count
  end
  def matched_reservation_decorator
    @matched_reservation_decorator ||= MatchedReservationDecorator.new(@venue_booking.matched_reservation)
  end

  def first_reservation_name
    if first_reservation.user.gender == 'male' && second_reservation.user.gender == 'female'
      second_reservation.user.first_name
    else
      first_reservation.user.first_name
    end
  end

  def second_reservation_name
    if first_reservation.user.gender == 'female' && second_reservation.user.gender == 'male'
      second_reservation.user.first_name
    else
      first_reservation.user.first_name
    end
  end

  def first_reservation
    matched_reservation_decorator.first_reservation_decorator
  end

  def second_reservation
    matched_reservation_decorator.second_reservation_decorator
  end


  def booking_day
    schedule.strftime("%A #{I18n.t('admin.terms.night').downcase}")
  end

  def booking_date
    schedule.strftime('%A, %B %d')
  end

  def booking_time
    schedule.strftime('%l:%M %p')
  end
end
