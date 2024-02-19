class UserCreditScope
  def initialize(user)
    @user = user
  end

  def total_credits
    @total_credits ||= @user.credits.where({ action: 'add', currency: currency }).sum(:amount)
  end

  def used_credits
    @used_credits ||= @user.credits.where({ action: 'deduct', currency: currency }).sum(:amount)
  end

  def available_credits
    @available_credits ||= (total_credits - used_credits).to_i
  end

  def credits_can_use
    if available_credits >= fee.to_i
      fee
    else
      available_credits
    end
  end

  def has_credits?
    available_credits > 0
  end

  private

  def fee
    APP_CONFIG['fee'][@user.location][@user.gender]
  end

  def currency
    APP_CONFIG['fee_currency'][@user.location]
  end
end
