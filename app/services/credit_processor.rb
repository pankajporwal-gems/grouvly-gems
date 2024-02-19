class CreditProcessor
  attr_reader :referrer_credit

  def initialize(user)
    @user ||= user
  end

  def reward_referral
    user_credit.amount = APP_CONFIG['referral_reward'][@user.location]
    user_credit.action = 'add'
    user_credit.activity = 'signup'
    user_credit.actor_id = referrer.present? ? referrer.id : @user.id
    user_credit.currency = APP_CONFIG['fee_currency'][@user.location]
    user_credit.save!
  end

  def reward_referrer
    referrer_credit.amount = APP_CONFIG['referral_reward'][referrer.location]
    referrer_credit.action = 'add'
    referrer_credit.activity = 'referrer'
    referrer_credit.actor_id = @user.id
    referrer_credit.currency = APP_CONFIG['fee_currency'][referrer.location]
    referrer_credit.save!
  end

  def deduct_credit(actor_type, actor_id)
    user_credit.amount = @user.credits_can_use
    user_credit.action = 'deduct'
    user_credit.activity = 'payment'
    user_credit.actor_type = actor_type
    user_credit.actor_id = actor_id
    user_credit.currency = APP_CONFIG['fee_currency'][@user.location]
    user_credit.save!
  end

  def referrer_credit
    @referrer_credit ||= Credit.new({ user_id: referrer.id })
  end

  def expire_credit(credit)
    user_credit.amount = credit.amount
    user_credit.action = 'deduct'
    user_credit.activity = 'expired'
    user_credit.actor_id = credit.user.id
    user_credit.currency = credit.currency
    user_credit.save!
  end

  private

  def referrer
    @referrer ||= @user.referrer
  end

  def user_credit
    @credit ||= Credit.new({ user_id: @user.id })
  end
end
