class VenueStatistics
  def self.query_by_location(location)
    Venue.where(location: location)
  end

  def self.query_by_location_and_capacity_on_schedule(location, schedule)
    Venue.available_for_booking(schedule).where(location: location)
  end
end