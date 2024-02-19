class UserPaymentScope
  def initialize(user)
    @user = user
  end

  def total_revenue
    @user.cards.joins('INNER JOIN payments ON payments.card_id = cards.id')
      .where(payments: { method: 'capture', status: 'success' }).sum(:amount)
  end
end
