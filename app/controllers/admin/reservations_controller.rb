class Admin::ReservationsController < Admin::AdminsController
  def index
    @presenter = ListReservationsPresenter.new(reservation_filter_params)
  end

  def capture_all_payments
    if result == 'ALL_PAID'
      render json: { errors: I18n.t('admin.matches.show.all_paid') }, status: 404
    elsif result == 0
      reservation.complete_match
      render json: { message: I18n.t('admin.matches.show.all_payments_captured') }
    else
      render json: { errors: error_messages }, status: 404
    end
  end

  def refund_amount
    if params[:member_id].present?
      if params[:refund_amount].present?
        status, error_type = payment_processor.refund_amount_for_member(params[:member_id], params[:refund_amount])
        if status
          flash[:notice] = t('admin.reservations.refund_amount.success', amount: params[:refund_amount].to_f)
        else
          case error_type
          when "not_settled"
            flash[:error] = t('admin.reservations.refund_amount.error.not_settled')
          when "not_less_then"
            flash[:error] = t('admin.reservations.refund_amount.error.not_less_then')
          else
            flash[:error] = t('admin.reservations.refund_amount.error.other_error')
          end
        end
      else
        flash[:error] = t('admin.reservations.refund_amount.error.no_refund_amount')
      end
    else
      flash[:error] = t('admin.reservations.refund_amount.error.not_member')
    end
    redirect_to :back
  end


  def cancel_booking
    result = payment_processor.refund_total_amount
    if result
      if reservation.cancel!
        # ReservationMailer.notify_about_cancel_reservation(reservation.id).deliver_later
        notification = { msg: I18n.t('admin.matches.show.cancel_booking', user_name: reservation.user.name, date: reservation.schedule.strftime('%d %b %Y (%a) at %l:%M %p')), result: true }
      else
        notification = { msg: I18n.t('admin.matches.show.already_cancelled'), result: false  }
      end
    else
      notification = { msg: I18n.t('admin.matches.show.not_refunded'), result: false }
    end
    respond_to do |format|
      format.json { render json: notification }
    end
  end

  private

  def reservation
    @reservation ||= Reservation.where("slug = ?", params[:id]).first
  end

  def payment_processor
    @payment_processor ||= PaymentProcessor.new(reservation)
  end


  def result
    @result ||= payment_processor.capture_all_payments
  end

  def error_messages
    reservation.payments.where(method: 'capture', status: 'error').map(&:message)
  end

  def reservation_filter_params
    params.permit(:location, :start_date, :end_date, :gender, :name)
  end
end
