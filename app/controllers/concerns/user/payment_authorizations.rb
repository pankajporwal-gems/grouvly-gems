module User::PaymentAuthorizations
  extend ActiveSupport::Concern

  included do
    skip_before_filter :check_user_blocked
    skip_before_filter :check_user_rejected
    skip_before_filter :check_user_deauthorized
    skip_before_filter :check_user_pending
    before_filter :check_reservation_date, except: [:validate_voucher]
    before_filter :check_reservation_is_full, except: [:validate_voucher]
    before_filter :check_user_already_has_reservation, except: [:validate_voucher]
    before_filter :check_user_same_gender, except: [:validate_voucher]
    before_filter :check_if_user_can_make_new_payments, except: [:validate_voucher]
  end

  private

  def check_reservation_date
    if schedule
      user_type = "admin" if reservation.last_minute_booking
      if ((Grouvly::ReservationDate.is_schedule_with_most_recent_valid?(schedule) &&
        schedule < Chronic.parse('now') && current_user != reservation.user) ||
        (!Grouvly::ReservationDate.is_schedule_valid?(schedule, user_type) && current_user == reservation.user))
        flash[:error] = t('user.reservations.errors.messages.you_have_not_chosen_a_valid_schedule')
        redirect_to new_user_reservation_url and return
      end
    else
      render not_found
    end
  end

  def check_reservation_is_full
    if reservation.is_full?
      flash[:error] = t('user.reservations.errors.messages.this_grouvly_date_is_already_full')
      redirect_to new_user_reservation_url and return
    end
  end

  def check_user_already_has_reservation
    if payment.status != "pending"
      if current_user.has_paid_reservation_on?(schedule)
        flash[:error] = I18n.t('user.payments.errors.paid_reservation_exists_error')
        redirect_to new_user_reservation_url and return
      end
    end
  end

  def check_user_same_gender
    user = reservation.user

    if !reservation.new_record? && !current_user.has_same_gender_as?(user)
      user_decorator = UserDecorator.new(user)
      flash[:error] = I18n.t('user.payments.errors.needs_proper_wing_gender', user: user.first_name,
        wing: user_decorator.wing_type)
      redirect_to join_reservation_url(reservation.slug) and return
    end
  end

  def check_if_user_can_make_new_payments
    redirect_to finish_user_membership_url and return if reservation.new_record? && !current_user.accepted?
  end
end
