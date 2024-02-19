class ListPoolsPresenter
  attr_reader :location, :total_free_guys, :total_free_girls, :total_matches, :pools

  def initialize(options={})
    if options[:location]
      @location ||= options[:location]
      @data ||= ReservationStatistics.get_pool_stats_by_location(@location)
    else
      @data ||= ReservationStatistics.get_pool_stats
    end

    @total_free_guys ||= @data[0]
    @total_free_girls ||= @data[1]
    @total_matches ||= @data[2]
    @pools ||= @data[3]
  end
end
