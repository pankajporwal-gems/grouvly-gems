class SendLeadPaymentEmailJob < ActiveJob::Base
  queue_as :mailers

  def perform(payment_id)
    @payment = Payment.find(payment_id)
    # PaymentMailer.email_lead(@payment).deliver_later
  end
end
