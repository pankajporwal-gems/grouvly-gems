class SendVenueLocationDetailsJob < ActiveJob::Base
  queue_as :mailers

  def perform(venue_booking_notification_id)
    @venue_notification = VenueBookingNotification.find(venue_booking_notification_id)
    # PoolsMatchedMailer.send_venue_location_details(@venue_notification).deliver_later
  end
end
