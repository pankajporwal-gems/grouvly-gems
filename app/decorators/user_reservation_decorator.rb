class UserReservationDecorator
  def initialize(user, reservation)
    @user ||= user
    @reservation ||= reservation
  end

  def payment
    @reservation.all_valid_payments.joins(card: :user).where(users: { id: @user.id }).first
  end
end
