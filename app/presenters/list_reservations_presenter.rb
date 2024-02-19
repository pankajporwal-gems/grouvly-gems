class ListReservationsPresenter
  attr_reader :location, :total_free_guys, :total_free_girls, :reservations

  def initialize(options={})
    @location ||= options[:location]
    @data ||= ReservationStatistics.get_reservation_stats(options)
    @total_free_guys ||= @data[0]
    @total_free_girls ||= @data[1]
    @reservations ||= @data[2]
  end
end
