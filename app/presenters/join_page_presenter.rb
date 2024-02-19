class JoinPagePresenter
  attr_reader :user

  def initialize(user)
    @user ||= user
  end

  def referrer_pronoun
    @referrer_pronoun ||= if @user.gender == 'male'
      I18n.t('user.reservations.join.his')
    else
      I18n.t('user.reservations.join.her')
    end
  end

  def discount_amount
    APP_CONFIG['referral_reward'][location]
  end

  def currency
    APP_CONFIG['referral_currency'][location]
  end

  private

  def location
    @user.location
  end
end
