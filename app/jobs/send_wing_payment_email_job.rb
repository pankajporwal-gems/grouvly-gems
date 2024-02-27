class SendWingPaymentEmailJob < ActiveJob::Base
  queue_as :mailers

  def perform(payment_id)
    @payment = Payment.find(payment_id)
    # PaymentMailer.email_wing(@payment).deliver_later
  end
end
