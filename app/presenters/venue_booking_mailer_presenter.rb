class VenueBookingMailerPresenter
  attr_reader :venue_booking

  delegate :schedule, :booking_date, :booking_time, :first_reservation_name, :participents_count, :second_reservation_name, to: :venue_booking_decorator

  def initialize(venue_booking)
    @venue_booking ||= venue_booking
  end

  def venue_booking_decorator
    @venue_booking_decorator = VenueBookingDecorator.new(@venue_booking)
  end

  def style_yes_button
    style_button('#5CB85C')
  end

  def style_no_button
    style_button('#D9534F')
  end

  private

  def style_button(background_color)
    css = "background-color: #{background_color}; color: white; font-size: 15px; width: 120px; padding: 10px 0;"
    css += "display: inline-block; text-align: center; text-transform: uppercase; text-decoration: none; text-align: center; border-radius: 4px;"
  end
end