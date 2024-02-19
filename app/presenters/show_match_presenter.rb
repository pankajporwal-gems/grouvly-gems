class ShowMatchPresenter
  attr_reader :location, :schedule, :matched_reservations

  def initialize(location, schedule, matched_reservations)
    @location = location
    @schedule = schedule
    @matched_reservations = matched_reservations
  end

  def available_venues
    all_venues = VenueStatistics.query_by_location(@location)
    available_venues = VenueStatistics.query_by_location_and_capacity_on_schedule(@location, @schedule)

    if all_venues.any?
      all_venues.collect do |venue|
        is_disabled = !available_venues.any? { |v| v.id == venue.id }

        ["#{venue.neighborhood} - #{venue.name}", venue.id, { disabled: is_disabled }]
      end
    end
  end

  def available_time_slots
    time_slots = []

    if APP_CONFIG['available_venue_time_slots'].any?
      APP_CONFIG['available_venue_time_slots'].each do |time_slot|
        time_slots << [time_slot, Chronic.parse("#{schedule_date} at #{time_slot}").to_s]
      end
    end

    time_slots
  end

  private

  def schedule_date
    Chronic.parse(@schedule).strftime('%Y-%m-%d') if @schedule
  end
end
