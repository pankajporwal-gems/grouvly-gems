class ListMatchesPresenter
  attr_reader :location, :total_matches, :matches

  def initialize(options={})
    if options[:location]
      @location ||= options[:location]
      @data ||= ReservationStatistics.get_match_stats_by_location(@location)
    else
      @data ||= ReservationStatistics.get_match_stats
    end

    @total_matches ||= @data[0]
    @matches ||= @data[1]
  end
end
