class InquiryMailer < BaseMailer
  def inquire(inquiry)
    @inquiry = inquiry

    set_concierge_details

    mail(from: APP_CONFIG['support_email'], to: @inquiry.email_address,
      subject: t('mailers.inquiry.subject'))
  end

  def notify_support(inquiry)
    @inquiry = inquiry

    set_concierge_details

    mail(from: @inquiry.email_address, to: APP_CONFIG['support_email'],
      subject: t('mailers.inquiry.support_subject'))
  end
end
