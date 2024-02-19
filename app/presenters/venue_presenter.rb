class VenuePresenter
  attr_reader :venue

  def initialize(venue)
    @venue ||= venue
  end

  def venue_types
    APP_CONFIG['venue_types']
  end

  def available_locations
    APP_CONFIG['available_locations']
  end

  def available_neighborhoods
    APP_CONFIG['available_neighborhoods'] | [I18n.t('terms.others')]
  end

  def booking_days
    APP_CONFIG['available_venue_booking_days']
  end

  def is_other_neighborhood?
    !self.available_neighborhoods.include? @venue.neighborhood
  end

  private

  def location
    if @venue.location.present?
      @venue.location
    else
      APP_CONFIG['available_locations'][0]
    end
  end
end
