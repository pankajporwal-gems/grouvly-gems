class MatchedReservationDecorator
  def initialize(matched_reservation)
    @matched_reservation ||= matched_reservation
  end

  def first_reservation_decorator
    @first_reservation_decorator = UserDecorator.new(@matched_reservation.first_reservation.user)
  end

  def second_reservation_decorator
    @first_reservation_decorator = UserDecorator.new(@matched_reservation.second_reservation.user)
  end

  def total_participents_count
    2 + @matched_reservation.first_reservation.wing_quantity + @matched_reservation.second_reservation.wing_quantity
  end
end
