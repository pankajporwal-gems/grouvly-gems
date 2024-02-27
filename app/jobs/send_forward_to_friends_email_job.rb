class SendForwardToFriendsEmailJob < ActiveJob::Base
  queue_as :mailers

  def perform(payment_id)
    @payment = Payment.find(payment_id)
    # PaymentMailer.forward_to_friends(@payment).deliver_later
  end
end
