class ConfirmedReservationPresenter
  delegate :user, :lead, :participants, :just_the_date, :just_the_time, :wing_quantity, :participants_count, :reservation_slug, to: :invite_wings_reservation_presenter
  delegate :wing_type, to: :user_decorator

  attr_reader :reservation

  def initialize(reservation, current_user)
    @reservation ||= reservation
    @current_user ||= current_user
  end

  def user_decorator
    @user_decorator ||= UserDecorator.new(user)
  end

  def invite_wings_reservation_presenter
    @invite_wings_reservation_presenter = InviteWingsReservationPresenter.new(@reservation)
  end

  def wing?
    if @current_user == user
      return false
    else
      return true
    end
  end
end
