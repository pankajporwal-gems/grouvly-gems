module Admin::Payments
  extend ActiveSupport::Concern

  private

  def payment_params
    params.require(:payment).permit(:name, :voucher_code, reservation_attributes: [:schedule, :id, :last_minute_booking])
  end

  def only_payment_params
    payment_params.except(:reservation_attributes)
  end

  def get_payment_with_reservation
    payment = Payment.new(only_payment_params)
    payment.reservation = Reservation.find(payment_params[:reservation_attributes][:id])
    payment
  end

  def payment
    @payment ||= if params[:payment]
      get_payment_with_reservation
    else
      Payment.new({ reservation: new_reservation })
    end
  end

  def build_schedule
    reservation = @user.reservations.active.where(schedule: params[:schedule]).first

    reservation = @user.reservations.build({ schedule: params[:schedule], user_type: "admin" }) if reservation.blank?

    reservation.update_attribute("user_type", "admin")
    reservation
  end

  def new_reservation
    @reservation ||= if params[:schedule]
      build_schedule
    end
  end

  def payment_collector
    @payment_collector ||= PaymentCollector.new(@user, payment)
  end

  def set_other_payment_info
    payment.amount = @new_payment_presenter.fee
    payment.currency = @new_payment_presenter.currency
    payment.user = @user
    payment.name = @user.name
    if @user.valid_cards.present?
      payment.card = @user.active_card
      payment.status = "success"
    else
      payment.status = "pending"
    end
  end

  def send_emails
    if reservation.user == @user
      if payment.status == "success"
        SendLeadPaymentEmailJob.perform_now(payment.id)
        SendForwardToFriendsEmailJob.perform_now(payment.id)
      elsif payment.status == "pending"
        SendPendingPaymentEmailJob.perform_now(payment.id)
      end
    end
  end
end
