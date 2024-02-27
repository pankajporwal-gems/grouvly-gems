class SendVenueTableBookingJob < ActiveJob::Base
  queue_as :mailers

  def perform(venue_id, venue_bookings)
    @venue = Venue.find(venue_id)
    # PoolsMatchedMailer.send_table_booking_to_venues(@venue, venue_bookings).deliver_later
  end
end
