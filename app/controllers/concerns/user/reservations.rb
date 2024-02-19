module User::Reservations
  extend ActiveSupport::Concern

  private

  def reservation_params
    params.require(:reservation).permit(:schedule, :last_minute_booking)
  end

  def reservation
    @reservation ||= if params[:reservation]
      reservation = current_user.reservations.active.where(schedule: reservation_params[:schedule]).first

      if reservation.blank?
        reservation =  Reservation.new(reservation_params.merge(user_id: current_user.id))
      end

      reservation
    elsif params[:id]
      reservation = Reservation.where(slug: params[:id]).first
      render not_found and return if reservation.blank?
      reservation
    else
      Reservation.new({ user: current_user })
    end
  end

  def pending_reservation
    reservations = current_user.reservations.active.in_state(:pending_payment)
    if reservations.present?
      reservations.order(:schedule).first
    end
  end

  def lead
    @lead ||= reservation.user
  end

  def set_join_grouvly_session
    session[:join_grouvly_url] = request.original_url if current_user.blank?
  end
end
