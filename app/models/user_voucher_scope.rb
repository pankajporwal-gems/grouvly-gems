class UserVoucherScope
  def initialize(user)
    @user = user
  end

  def vouchers_used
    @vouchers_used ||= Voucher.joins({ payments: { card: :user } }).where(users: { id: @user.id })
      .where("(payments.status = 'success' AND payments.method = 'authorize') OR payments.method IN ('capture', 'refund')")
  end

  def total_vouchers
    @total_vouchers ||= vouchers_used.count
  end

  def has_redeemed_voucher?(voucher)
    vouchers_used.where(vouchers: { id: voucher.id }).count > 0
  end

  def has_already_relunch_redeemed_voucher?
    vouchers_used.where(vouchers: { description: "Relaunch voucher"}).count > 0
  end
end
