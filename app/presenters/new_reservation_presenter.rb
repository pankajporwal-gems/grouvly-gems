class NewReservationPresenter
  attr_reader :reservation

  delegate :first_date, :second_date, :third_date, :custom_dates, :available_dates, :admin_available_dates, :last_minute_booking_date, :available_admin_dates, :unavailable_dates,
    to: :reservation_date_decorator

  def initialize(reservation)
    @reservation ||= reservation
  end

  def user
    @user ||= @reservation.user
  end

  def reservation_date_decorator
    @reservation_date_decorator ||= ReservationDateDecorator.new(user)
  end

end
