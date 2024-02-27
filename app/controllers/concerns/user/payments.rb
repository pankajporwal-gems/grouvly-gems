module User::Payments
  extend ActiveSupport::Concern

  private

  def payment_params
    params.require(:payment).permit(:name, :voucher_code, reservation_attributes: [:schedule, :id, :wing_quantity])
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
      Payment.new({ reservation: reservation })
    end
  end

  def build_schedule
    render not_found and return unless current_user.accepted?

    reservation = current_user.reservations.active.where(schedule: params[:schedule]).first

    if reservation.blank?
      reservation = current_user.reservations.build({ schedule: params[:schedule]})

      if reservation.save
        return reservation
      else
        flash.now[:error] = I18n.t('user.reservations.cannot_process_payment')
        redirect_to new_user_reservation_url
      end
    else
      return reservation
    end
  end

  def reservation
    @reservation ||= if params[:schedule]
      build_schedule
    elsif params[:reservation]
      Reservation.where(slug: params[:reservation]).first
    elsif params[:payment]
      Reservation.find(params[:payment][:reservation_attributes][:id])
    end

    if @reservation.blank?
      render not_found
    else
      if params[:payment] && params["payment"]["reservation_attributes"]["wing_quantity"]
        @reservation.update_attribute("wing_quantity", params["payment"]["reservation_attributes"]["wing_quantity"])
      end
      @reservation.update_attribute("last_minute_booking", true) if is_last_minute_booking?(@reservation.schedule)
      @reservation
    end
  end

  def is_last_minute_booking?(upcoming_date)
    if upcoming_date.present?
      upcoming_date = upcoming_date
      before_48_hours = upcoming_date - 48.hours
      before_4_hours = upcoming_date - 4.hours
      current_time = Chronic.parse('now')
      current_time >= before_48_hours && current_time < before_4_hours
    else
      false
    end
  end

  def schedule
    schedule = if reservation
      reservation.schedule
    elsif params[:payment]
      params[:payment][:reservation_attributes][:schedule]
    end
  end

  def user_type
    user_type = if reservation
      reservation.user_type
    elsif params[:payment]
      params[:payment][:reservation_attributes][:user_type]
    end
  end

  def payment_collector
    @payment_collector ||= PaymentCollector.new(current_user, payment)
  end

  def set_other_payment_info
    BRAINTREE_LOGGER.info("payment_method_nonce :: #{params[:payment_method_nonce]}")
    @reservation.update_attribute(:last_minute_booking, true) if @new_payment_presenter.last_minute_booking
    payment.payment_method_nonce = params[:payment_method_nonce]
    payment.amount = fee
    payment.currency = @new_payment_presenter.currency
    payment.user = current_user
  end

  def fee
    @fee = if voucher.present?
      voucher_decorator.fee
    else
      @reservation.last_minute_booking ? @new_payment_presenter.total_fee : @new_payment_presenter.payment_fee
    end
    @fee
  end

  def voucher
    voucher = Voucher.where(slug: params[:payment][:voucher_code]).first if params[:payment][:voucher_code].present?
  end

  def voucher_decorator
    @user_voucher_decorator = UserVoucherDecorator.new(current_user, voucher, @reservation.last_minute_booking)
  end

  def send_emails
    if reservation.user == current_user
      SendLeadPaymentEmailJob.perform_now(payment.id)
      SendForwardToFriendsEmailJob.perform_now(payment.id)
      redirect_to invite_wings_user_reservation_url(reservation.slug) and return
    else
      SendWingPaymentEmailJob.perform_now(payment.id)
      redirect_to confirmed_user_reservation_url(reservation.slug) and return
    end
  end
end
