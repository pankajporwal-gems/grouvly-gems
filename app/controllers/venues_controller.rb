class VenuesController < ApplicationController
  layout 'feedback'

  before_action :booking_params

  rescue_from ActionController::ParameterMissing do |exception|
    redirect_to root_url, alert: exception.message
  end

  def confirm_booking
    booking_params.each do |booking|
      venue_booking = VenueBooking.where(slug: booking).first
      venue_booking.accept!
    end
  end

  def reject_booking
    booking_params.each do |booking|
      venue_booking = VenueBooking.where(slug: booking).first
      venue_booking.reject!
    end
  end

  private

  def booking_params
    params.require(:booking)
  end
end