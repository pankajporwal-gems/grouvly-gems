class SendPaymentReceiptJob < ActiveJob::Base
  queue_as :mailers

  def perform(payment_id)
    @payment = Payment.find(payment_id)
    # PaymentMailer.email_receipt(@payment).deliver_later
    # PaymentMailer.email_receipt_to_accounting(@payment).deliver_later
  end
end
