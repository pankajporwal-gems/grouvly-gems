Fabricator(:venue_booking) do
  venue { Fabricate(:venue) }
  matched_reservation { Fabricate(:matched_reservation) }
  schedule { Chronic.parse('next Thursday at 8pm') }
end
