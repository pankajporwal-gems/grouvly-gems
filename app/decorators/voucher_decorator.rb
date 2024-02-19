class VoucherDecorator
  def initialize(voucher)
    @voucher = voucher
  end

  def type
    @voucher.voucher_type.titleize
  end

  def start_date
    @voucher.start_date.strftime('%B %d, %Y') if @voucher.start_date
  end

  def end_date
    @voucher.end_date.strftime('%B %d, %Y') if @voucher.end_date
  end

  def gender
    @voucher.gender.titleize if @voucher.gender
  end

  def user
    user_decorator.name if @voucher.user
  end

  def restriction
    @voucher.restriction.titleize
  end

  private

  def user_decorator
    @user_decorator ||= UserDecorator.new(@voucher.user)
  end
end
