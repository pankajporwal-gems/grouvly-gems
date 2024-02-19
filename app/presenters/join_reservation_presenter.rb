class JoinReservationPresenter
  delegate :reservation_date, :just_the_time, to: :invite_wings_reservation_presenter

  def initialize(reservation, user)
    @user ||= user
    @reservation ||= reservation
    @app_id ||= ENV['FACEBOOK_APP_ID']
    @app_secret ||= ENV['FACEBOOK_APP_SECRET']
    @callback_url ||= ENV['FACEBOOK_CALLBACK_URL']
    @permissions ||= APP_CONFIG['facebook_permissions']
    @oauth ||= Koala::Facebook::OAuth.new(@app_id, @app_secret, @callback_url)
  end

  def lead
    @lead ||= @reservation.user
  end

  def lead_first_name
    @lead_first_name ||= lead.first_name
  end

  def lead_name
    user_decorator.name
  end

  def lead_pronoun
    @lead_pronoun ||= if lead.gender == 'male'
      I18n.t('user.reservations.join.his')
    else
      I18n.t('user.reservations.join.her')
    end
  end

  def fee
   @fee ||= @reservation.last_minute_booking ? payment_fee.to_i +  express_fee.to_i : payment_fee
  end

  def payment_fee
    APP_CONFIG['fee'][lead.location][lead.gender]
  end

  def express_fee
    APP_CONFIG['express_fee'][lead.location]
  end

  def fee_currency
    @fee_currency ||= APP_CONFIG['fee_currency'][lead.location]
  end

  def login_url
    if @user.present?
      Rails.application.routes.url_helpers.new_user_payment_path({ reservation: @reservation.slug })
    else
      @oauth.url_for_oauth_code({ permissions: @permissions })
    end
  end

  private

  def invite_wings_reservation_presenter
    @invite_wings_reservation_presenter ||= InviteWingsReservationPresenter.new(@reservation)
  end

  def voucher
    @reservation.all_valid_payments.first.voucher
  end

  def user_decorator
    @user_decorator ||= UserDecorator.new(lead)
  end

  def user_voucher_decorator
    @user_voucher_decorator ||= UserVoucherDecorator.new(lead, voucher)
  end
end
