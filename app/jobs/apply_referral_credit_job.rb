class ApplyReferralCreditJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)
    credit_processor.reward_referral

    if @user.referrer.present?
      credit_processor.reward_referrer

      if @user.referrer.accepted?
        # CreditMailer.send_reward_email_to_referrer(credit_processor.referrer_credit).deliver_later
      end
    end
  end

  private

  def credit_processor
    @credit_processor ||= CreditProcessor.new(@user)
  end
end
