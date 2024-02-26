class InviteWingsReservationPresenter
  delegate :wing_type, to: :user_decorator

  attr_reader :reservation

  def initialize(reservation)
    @reservation ||= reservation
  end

  def user
    @user ||= @reservation.user
  end

  def user_decorator
    @user_decorator ||= UserDecorator.new(user)
  end

  def just_the_date
    DateTime.parse(@reservation.schedule).strftime('%B %d')
  end

  def just_the_time
    DateTime.parse(@reservation.schedule).strftime('%l:%M %p')
  end

  def previous_date_of_schedule
    (DateTime.parse(@reservation.schedule) - 1.day).strftime('%A, %B %d')
  end

  def reservation_date
    DateTime.parse(@reservation.schedule).strftime('%A, %B %d')
  end

  def payments
    @payments ||= @reservation.payments
  end

  def lead
    @lead ||= @reservation.user
  end

  def participants
    @participants ||= @reservation.wings << @reservation.user
  end

  def reservation_slug
    @slug ||= @reservation.slug
  end

  def wing_quantity
    @reservation.wing_quantity
  end

  def participants_count
    @reservation.wing_quantity +  1
  end
end
