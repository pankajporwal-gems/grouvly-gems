class PaymentMailer < BaseMailer
  def email_wing(payment)
    set_variables(payment)

    @user = @payment_mailer_presenter.user

    set_concierge_details

    subject = t('mailers.payment.email_wing.subject', date: @payment_mailer_presenter.date )

    mail(to: @user.email_address, subject: subject)
  end

  def email_lead(payment)
    set_variables(payment)

    @user = @payment_mailer_presenter.lead

    set_concierge_details

    subject = t('mailers.payment.email_lead.subject', lead: @user.first_name,
      date: @payment_mailer_presenter.date)

    mail(to: @user.email_address, cc: APP_CONFIG['support_email'], subject: subject)
  end

  def email_receipt(payment)
    set_variables(payment)
    set_concierge_details
    subject = t('mailers.payment.email_receipt.subject')

    mail(to: @payment_mailer_presenter.user.email_address, subject: subject)
  end

  def email_receipt_to_accounting(payment)
    set_variables(payment)

    subject = t('mailers.payment.email_receipt.subject')

    mail(to: APP_CONFIG['accounting_email'], subject: subject)
  end

  def email_payment_error(payment, user)
    @payment = payment
    @user = user
    subject = t('mailers.payment.email_payment_error.subject')

    mail(to: APP_CONFIG['accounting_email'], cc: APP_CONFIG['support_email'], subject: subject)
  end

  def forward_to_friends(payment)
    set_variables(payment)

    @user = @payment_mailer_presenter.lead

    set_concierge_details

    subject = t('mailers.payment.forward_to_friends.subject', date: @payment_mailer_presenter.date)

    mail(to: @user.email_address, subject: subject)
  end

  def email_pending(payment)
    set_variables(payment)

    @user = @payment_mailer_presenter.lead

    set_concierge_details

    subject = t('mailers.payment.email_pending.subject', lead: @user.first_name)

    mail(to: @user.email_address, cc: APP_CONFIG['support_email'],  subject: subject)
  end

  private

  def set_variables(payment)
    @payment_mailer_presenter ||= PaymentMailerPresenter.new(payment)
  end
end
