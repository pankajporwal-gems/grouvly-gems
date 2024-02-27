class SendPaymentErrorJob < ActiveJob::Base
  queue_as :mailers

  def perform(payment_id, user_id)
    @payment = Payment.find(payment_id)
    @user = User.find(user_id)
    # PaymentMailer.email_payment_error(@payment, @user).deliver_later
  end
end
