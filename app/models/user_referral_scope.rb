class UserReferralScope
  def initialize(user)
    @user = user
  end

  def referrer
    Referral.referrer(@user.id)
  end

  def valid_referrals
    @user.referrals.where('referrals.created_at >= ?', APP_CONFIG['referral_program_start_date'][@user.location])
      .joins('LEFT JOIN users ON users.id = referrals.referral_id')
      .joins('LEFT JOIN user_transitions ON user_transitions.user_id = referrals.referral_id')
      .where('user_transitions.to_state = ?', 'accepted')
  end

  def delete_referrer
    Referral.where(referral_id: @user.id).destroy_all
  end
end
