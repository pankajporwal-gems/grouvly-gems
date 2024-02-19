class UserVoucherDecorator
  def initialize(user, voucher, last_minute_booking=nil)
    @user = user
    @voucher = voucher
    @last_minute_booking = last_minute_booking
  end

  def fee
    total_amount = payment_fee
    total_amount = total_amount + express_fee if @last_minute_booking
    @fee = if @voucher.voucher_type == 'cash'
      total_amount - @voucher.amount
    else
      total_amount - (total_amount * (@voucher.amount / 100))
    end

    if (@fee % 1) == 0
      @fee.to_i
    else
      @fee
    end
  end

  private

  def express_fee
    @express_fee ||= APP_CONFIG['express_fee'][@user.location].to_i
  end

  def payment_fee
    @payment_fee ||= APP_CONFIG['fee'][@user.location][@user.gender].to_i
  end
end
