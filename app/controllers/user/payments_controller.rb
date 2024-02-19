class User::PaymentsController < User::UsersController
  include User::PaymentAuthorizations
  include User::Payments
  include User::UserTracking

  def new
    if updated_profile?
      session.delete(:join_grouvly_url)
      gon.client_token = Grouvly::BraintreeApi.generate_client_token(current_user)
      payment.user = current_user
      get_active_card
      @new_payment_presenter = NewPaymentPresenter.new(payment)
      @reservation = Reservation.where(slug: params[:reservation]).first
      track_page(PAGE_RESERVATION_PAYMENT)
    else
      flash[:error] = I18n.t('user.payments.update_profile')
      redirect_to :back
    end
  end

  def create
    gon.client_token = Grouvly::BraintreeApi.generate_client_token(current_user)
    @new_payment_presenter = NewPaymentPresenter.new(payment)
    set_other_payment_info
    BRAINTREE_LOGGER.info("Payment :: #{payment.inspect}, user_id :: #{current_user.id}")
    if is_condition_accepted? && payment.save
      BRAINTREE_LOGGER.info("Payment_saved :: #{payment.inspect}")
      if payment.card.blank?
        if payment_collector.send(params[:different_card])
          payment.update_attributes({ card_id: payment_collector.credit_card.id, status: 'success' })
          payment_collector.update_credits

          payment_processor = PaymentProcessor.new(payment.reservation)
          result = payment_processor.capture_all_payments
          if result == 0
            payment.reservation.enter_payment! if payment.reservation.user == current_user
            BRAINTREE_LOGGER.info("payment_enterd :: #{payment.inspect}")

            BRAINTREE_LOGGER.info("payment_captured :: user => #{current_user.id}, amount => #{payment.amount}, payment_result: #{result} ")

            send_emails
            track_payment_complete
          else
            payment_error(payment, result)
          end
        else
          payment_error(payment, "problem creating customer and payment method")
        end
      elsif payment.card.present? && payment.card.token == 'free'
         BRAINTREE_LOGGER.info("payment :: payment.card.present? =>  #{payment.card.present? } and  payment.card.token => #{payment.card.token}")
        payment.reservation.enter_payment! if payment.reservation.user == current_user
        send_emails
        track_payment_complete
      end
    else
      unless is_condition_accepted?
         payment_error(payment, I18n.t('user.payments.check_conditions'))
      else
         payment_error(payment, payment.errors.messages)
      end
    end
  end

  def validate_voucher
    @voucher = Voucher.where(slug: params[:payment][:voucher_code]).first
    @last_minute_booking = params[:payment][:last_minute_booking] == "true" ? true : false

    if current_user.has_credits?
      render_voucher_cannot_be_used
    elsif @voucher.blank?
      render_voucher_is_invalid
    elsif @voucher.is_valid?(current_user)
      render_voucher_is_valid
    else
      render_voucher_is_invalid
    end
  end


  private

  def get_active_card
    unless params[:different_card].present?
      card = current_user.active_card
      @card = Grouvly::BraintreeApi.find_payment_method(card) if card.present?
    end
  end

  def is_condition_accepted?
    params["condition_first"] == "1" && params["condition_second"] == "1" && params["condition_third"] == "1" && params["condition_fourth"] == "1" && params["condition_fifth"] == "1"
  end


  def payment_error(payment, result)
    get_active_card
    payment.update_attribute(:status, 'error')

    BRAINTREE_LOGGER.info("payment_error :: #{payment.errors.messages}, payment_result: #{result}")

    flash.now[:error] = I18n.t('user.payments.we_cannot_process_your_card')
    render :new
  end

  def track_payment_complete
    event_properties = {
      revenue: payment.amount_in_usd,
      when: payment.created_at,
      dateGrouvly: payment.reservation.schedule
    }.merge(set_utm_properties)
    track_event(EVENT_PAYMENT_COMPLETED, event_properties)
  end

  def user_voucher_decorator
    @user_voucher_decorator ||= UserVoucherDecorator.new(current_user, @voucher, @last_minute_booking)
  end

  def render_voucher_cannot_be_used
    respond_to do |format|
      format.json {
        render json: {
          error: {
            title: I18n.t('user.payments.oops'),
            body: I18n.t('user.payments.errors.voucher_cannot_be_used')
          }
        }, status: :bad_request
      }
    end
  end

  def render_voucher_is_invalid
    respond_to do |format|
      format.json {
        render json: {
          error: {
            title: I18n.t('user.payments.oops'),
            body: I18n.t('user.payments.errors.voucher_invalid')
          }
        }, status: :bad_request
      }
    end
  end

  def render_voucher_is_valid
    respond_to do |format|
      format.json { render json: { amount: user_voucher_decorator.fee } }
    end
  end
end
