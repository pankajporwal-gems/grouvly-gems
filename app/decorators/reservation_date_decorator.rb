class ReservationDateDecorator
  def initialize(user)
    @user ||= user
  end

  def first_date
    @first_available_date ||= Grouvly::ReservationDate.first_available_date
  end

  def second_date
    @second_available_date ||= Grouvly::ReservationDate.second_available_date
  end

  def third_date
    @third_available_date ||= Grouvly::ReservationDate.third_available_date
  end

  def custom_dates
    @custom_available_dates ||= Grouvly::ReservationDate.custom_available_dates
  end

  def available_dates
    @available_dates ||= Grouvly::ReservationDate.available_valid_dates(@user)
  end

  def available_admin_dates
    @available_admin_dates ||= Grouvly::ReservationDate.available_admin_valid_dates(@user)
  end

  def admin_available_dates
    @admin_available_dates ||= Grouvly::ReservationDate.admin_available_valid_dates(@user)
  end

  def last_minute_booking_date
    @last_minute_booking_date ||= Grouvly::ReservationDate.last_minute_booking_date(@user)
  end

  def unavailable_dates
    @unavailable_dates ||= Grouvly::ReservationDate.unavailable_valid_dates(@user)
  end
end
