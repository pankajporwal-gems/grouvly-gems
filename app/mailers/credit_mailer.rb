class CreditMailer < BaseMailer
  def send_reward_email_to_referrer(credit)
    @presenter = CreditMailerPresenter.new(credit)
    @credit = credit
    @user = credit.user

    set_concierge_details

    mail(to: @user.email_address, subject: t('mailers.credit.referrer.subject', { amount: amount,
      currency: currency }))
  end

  def send_credit_reminder(days, credit)
    @presenter = CreditMailerPresenter.new(credit)
    @user = credit.user
    @credit = credit
    @days = days

    set_concierge_details

    mail(to: @user.email_address, subject: t('mailers.credit.reminder.other_days.subject', { amount: amount,
      currency: currency, first_name: @user.first_name }))
  end

  def send_credit_reminder_for_tomorrow(credit)
    @presenter = CreditMailerPresenter.new(credit)
    @user = credit.user
    @credit = credit

    set_concierge_details

    mail(to: @user.email_address, subject: t('mailers.credit.reminder.tomorrow.subject', { amount: amount,
      currency: currency, first_name: @user.first_name }))
  end

  def send_relaunch_email(user, voucher)
    @user = user
    @voucher = voucher
    type = @voucher.voucher_type == "percentage" ? "%" : ""
    @voucher_amount = @voucher.amount.to_i.to_s + type.to_s
    @end_date = @voucher.end_date.strftime('%B %d, %Y') if @voucher.end_date
    mail(to: @user.email_address, subject: t('mailers.credit.relaunch.subject', voucher: @voucher_amount))
  end

  private

  def amount
    @amount ||= @credit.amount.to_i
  end

  def currency
    @currency ||= @credit.currency
  end
end
