class SendInquiryJob < ActiveJob::Base
  queue_as :mailers

  def perform(inquiry)
    inquiry.delete 'validation_context'
    inquiry.delete 'errors'
    @inquiry = Inquiry.new(inquiry)
    InquiryMailer.inquire(@inquiry).deliver_now
    InquiryMailer.notify_support(@inquiry).deliver_now
  end
end
