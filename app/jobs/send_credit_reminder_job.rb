class SendCreditReminderJob < ActiveJob::Base
  queue_as :default

  def perform(no_of_days, credit_id)
    @credit = Credit.find(credit_id)

    if (no_of_days == 1)
      # CreditMailer.send_credit_reminder_for_tomorrow(@credit).deliver_later
    else
      # CreditMailer.send_credit_reminder(no_of_days, @credit).deliver_later
    end
  end
end
