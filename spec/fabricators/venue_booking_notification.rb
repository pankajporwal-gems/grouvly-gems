Fabricator(:venue_booking_notification) do
  venue_booking { Fabricate(:venue_booking) }
  matched_reservation { Fabricate(:matched_reservation) }
  reservation { Fabricate(:reservation) }
end
