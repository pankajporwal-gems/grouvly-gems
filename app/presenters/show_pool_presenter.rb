class ShowPoolPresenter
  def initialize(location, date, page)
    @location ||= location
    @date ||= date
    @page ||= page
  end

  def reservations
    @reservations ||= Reservation.upcoming.find_by_location(@location).find_by_schedule(@date).unmatched.page(@page)
  end

  def reservations_json
    (ActiveModel::ArraySerializer.new(reservations, each_serializer: ::ReservationSerializer)).to_json
  end

  def all_available_dates(old_date)
    date = old_date.in_time_zone
    a = [[date.strftime("%A, %B %d"), date]]
    b = Grouvly::ReservationDate.next_five_available_dates("admin")
    (a-b) | (b-a)
  end

  def available_valid_dates(user)
    Grouvly::ReservationDate.user_available_valid_dates(user)
  end

end
