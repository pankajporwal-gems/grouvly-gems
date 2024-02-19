class ReservationStatistics
  def self.get_reservation_stats(options = {})
    reservations = []
    total_free_guys = 0
    total_free_girls = 0
    #total_matches = 0

    locations = options[:location].present? ? [options[:location]] : APP_CONFIG['available_locations']

    locations.each do |location|
      #reservations = Reservation.find_by_location(location)
      #unmatched = reservations.unmatched
      #matched = reservations.matched
      #dates = unmatched.select('reservations.schedule').group('reservations.schedule').order('reservations.schedule desc')

      #dates.each do |available_date|
        #query = unmatched.where(reservations: { schedule: available_date.schedule })
        #free_guys = query.only_male.count
        #free_girls = query.only_female.count

        #matched_query_count = matched.where(reservations: { schedule: available_date.schedule }).count

        #total_free_guys += free_guys
        #total_free_girls += free_girls
        #total_matches += matched_query_count

        #pools << { location: location, date: available_date.schedule, free_guys: free_guys, free_girls: free_girls, matched: matched_query_count }
      #end
      #[total_free_guys, total_free_girls, total_matches, pools]

      query = Reservation.in_state(:cancelled, :payment_entered).find_by_location(location)

      start_date = options[:start_date].present? ? options[:start_date] : Chronic.parse('1 month ago at 12am')
      query = query.where('reservations.schedule >= ?', start_date)

      query = query.where('reservations.schedule <= ?', options[:end_date]) if options[:end_date].present?

      query = query.where(user_infos: { gender: options[:gender] }) if options[:gender].present?

      if options[:name]
        query = query.where("LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ?",
          "%#{options[:name]}%".downcase, "%#{options[:name]}%".downcase)
      end

      free_guys = query.only_male.size
      free_girls = query.only_female.size
      total_free_guys += free_guys
      total_free_girls += free_girls

      reservations << { location: location, free_guys: free_guys, free_girls: free_girls }
    end

    [total_free_guys, total_free_girls, reservations]
  end

  def self.get_pool_stats
    pools = []
    total_free_guys = 0
    total_free_girls = 0
    total_matches = 0

    APP_CONFIG['available_locations'].each do |location|
      query = Reservation.upcoming.find_by_location(location)
      unmatched_query = query.unmatched
      free_guys = unmatched_query.only_male.size
      free_girls = unmatched_query.only_female.size
      total_free_guys += free_guys
      total_free_girls += free_girls

      matched_query_count = query.matched.where('reservations.schedule >= ?', previous_thursday).count
      total_matches += matched_query_count

      pools << { location: location, free_guys: free_guys, free_girls: free_girls, matched: matched_query_count }
    end

    [total_free_guys, total_free_girls, total_matches, pools]
  end

  def self.get_pool_stats_by_location(location)
    total_free_guys = 0
    total_free_girls = 0
    total_matches = 0
    pools = []

    reservations = Reservation.upcoming.find_by_location(location)
    unmatched = reservations.unmatched
    matched = reservations.matched

    dates = unmatched.select('reservations.schedule').group('reservations.schedule').order('reservations.schedule desc')

    dates.each do |available_date|
      query = unmatched.where(reservations: { schedule: available_date.schedule })
      free_guys = query.only_male.count
      free_girls = query.only_female.count

      matched_query_count = matched.where(reservations: { schedule: available_date.schedule }).count

      total_free_guys += free_guys
      total_free_girls += free_girls
      total_matches += matched_query_count

      pools << { location: location, date: available_date.schedule, free_guys: free_guys, free_girls: free_girls,
        matched: matched_query_count }
    end

    [total_free_guys, total_free_girls, total_matches, pools]
  end

  def self.get_match_stats
    total_matches = 0
    matches = []

    APP_CONFIG['available_locations'].each do |location|
      query = Reservation.find_by_location(location)
      matched_query_count = query.matched.where('reservations.schedule >= ?', previous_thursday).count
      total_matches += matched_query_count
      matches << { location: location, matched: matched_query_count }
    end

    [total_matches, matches]
  end

  def self.get_match_stats_by_location(location)
    total_matches = 0
    matches = []
    dates = []

    reservations = Reservation.find_by_location(location)
    matched = reservations.matched

    dates = MatchedReservation.where.not(schedule: nil).select('matched_reservations.schedule').group('matched_reservations.schedule').order('matched_reservations.schedule desc')

    dates.each do |available_date|
      matched_query_count = matched.where(reservations: { schedule: available_date.schedule }).count
      if matched_query_count > 0
        total_matches += matched_query_count
        matches << { location: location, date: available_date.schedule, matched: matched_query_count }
      end
    end

    [total_matches, matches]
  end

  def self.get_all_valid_reservations
    Reservation.unmatched.where('reservations.schedule >= ?', previous_day)
  end

  def self.previous_day
    Chronic.parse('today at 8PM')
  end

  def self.previous_thursday
    Grouvly::ReservationDate.first_available_date - 7.days
  end
end
