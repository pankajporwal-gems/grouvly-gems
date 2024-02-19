class VenueNotificationMailerPresenter
  attr_reader :venue, :reservation

  delegate :schedule, :booking_day, :booking_date, :booking_time, to: :venue_booking_decorator
  delegate :wing_type, to: :user_decorator

  def initialize(venue_booking_notification)
    @venue_notification = venue_booking_notification
  end

  def user_first_name
    user.first_name
  end

  def slug
    @venue_notification.slug
  end

  def user
    @user = @venue_notification.reservation.user
  end

  def user_decorator
    @user_decorator = UserDecorator.new(user)
  end

  def venue_booking
    @venue_booking = VenueBooking.find(@venue_notification.venue_booking_id)
  end

  def venue_booking_decorator
    @venue_booking_decorator = VenueBookingDecorator.new(venue_booking)
  end

  def venue
    @venue = Venue.find(venue_booking.venue_id)
  end

  def reservation
    @reservation = Reservation.find(@venue_notification.reservation_id)
  end

  def schedule_has_changed?
    reservation.schedule != venue_booking.schedule
  end

  def original_schedule
    reservation.schedule.strftime('%l:%M %p')
  end

  def style_yes_button
    style_button('#5CB85C')
  end


  def first_reservation_name
    if first_reservation_user.gender == 'male' && second_reservation_user.gender == 'female'
      second_reservation_user.first_name
    else
      first_reservation_user.first_name
    end
  end

  def second_reservation_name
    if first_reservation_user.gender == 'female' && second_reservation_user.gender == 'male'
      second_reservation_user.first_name
    else
      first_reservation_user.first_name
    end
  end

  private

  def style_button(background_color)
    css = "background-color: #{background_color}; color: white; font-size: 15px; width: 120px; padding: 10px 0;"
    css += "display: inline-block; text-align: center; text-transform: capitalize; text-decoration: none; text-align: center; border-radius: 4px;"
  end

  def first_reservation
    venue_booking.matched_reservation.first_reservation
  end

  def second_reservation
    venue_booking.matched_reservation.second_reservation
  end

  def first_reservation_user
    first_reservation.user
  end

  def second_reservation_user
    second_reservation.user
  end
end
