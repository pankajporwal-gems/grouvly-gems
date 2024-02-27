class NewPaymentPresenter
  attr_reader :payment

  def initialize(payment)
    @payment ||= payment
  end

  def reservation
    @reservation ||= @payment.reservation
  end

  def last_minute_booking
    reservation.last_minute_booking
  end

  def slug
    @slug ||= reservation.slug
  end

  def lead
    @lead ||= reservation.user
  end

  def gender
    lead.gender
  end

  def schedule
    reservation.schedule
  end

  def reservation_date
    schedule.strftime('%A, %B %d')
  end

  def reservation_time
    schedule.strftime('%l:%M %p')
  end

  def fee
    @fee = if voucher.present?
      user_voucher_decorator.fee
    else
      fee = payment_fee.to_i
      fee = total_fee if last_minute_booking
      fee
    end
    @fee
  end

  def wing_fee
    last_minute_booking ? total_fee : payment_fee
  end

  def total_fee
    (payment_fee.to_i + express_fee.to_i).to_s
  end

  def express_fee
    APP_CONFIG['express_fee'][lead.location]
  end

  def payment_fee
    APP_CONFIG['fee'][lead.location][lead.gender]
  end


  def currency
    APP_CONFIG['fee_currency'][lead.location]
  end

  def available_wing_quantity
    APP_CONFIG['wing_quantity']
  end

  def user_location
    @country_code ||= ISO3166::Country.all.select { |c| c.first == lead.location }.flatten!
    [@country_code.last]
  end

  def show_zipcode?
    !['HK'].include?(user_location.first)
  end

  def available_credits
    @available_credits ||= @payment.user.available_credits
  end

  def credits_to_use
    @credits_to_use ||= @payment.user.credits_can_use
  end

  def has_credits?
    @payment.user.has_credits?
  end

  def wing?
    lead != @payment.user
  end

  def voucher
    reservation.all_valid_payments.each do |payment|
      return @payment.user == payment.card.user ? payment.voucher : nil
    end
  end

  def user_voucher_decorator
    @user_voucher_decorator ||= UserVoucherDecorator.new(@payment.user, voucher)
  end
end
