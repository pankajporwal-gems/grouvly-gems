class CreditMailerPresenter
  attr_reader :credit

  def initialize(credit)
    @credit = credit
  end

  def user
    @user ||= @credit.user
  end

  def first_name
    user.first_name
  end

  def referral_first_name
    @credit.actor.first_name
  end

  def amount
    @credit.amount.to_i
  end

  def currency
    APP_CONFIG['referral_currency'][user.location]
  end

  def total_credits
    user.total_credits.to_i
  end

  def available_credits
    user.available_credits.to_i
  end

  def referral_count
    user.valid_referrals.count
  end
end
