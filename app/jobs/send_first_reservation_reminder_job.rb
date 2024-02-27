class SendFirstReservationReminderJob < ActiveJob::Base
  queue_as :mailers

  def perform(user_id)
    @user = User.find(user_id)
    # ReservationMailer.send_first_reservation_reminder(@user).deliver_later
  end
end
