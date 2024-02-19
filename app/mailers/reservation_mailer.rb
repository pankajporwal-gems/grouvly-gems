class ReservationMailer < BaseMailer
  after_action :create_voucher, only: :notify_about_unmatched_reservation
  def send_first_reservation_invitation(user)
    @first_reservation_mailer_presenter = FirstReservationMailerPresenter.new(user)
    @first_reservation_mailer_presenter.deadline = 'tomorrow'
    @user = user

    set_concierge_details

    mail(to: user.email_address, subject: t('mailers.reservation.first_reservation_invitation.subject'))
  end

  def send_first_reservation_reminder(user)
    @first_reservation_mailer_presenter = FirstReservationMailerPresenter.new(user)
    @first_reservation_mailer_presenter.deadline = 'today'
    @user = user

    set_concierge_details

    mail(to: user.email_address, subject: t('mailers.reservation.first_reservation_reminder.subject'))
  end

  def notify_about_unmatched_reservation(user, reservation_id)
    @user = user
    @reservation_id = reservation_id
    set_concierge_details

    mail(to: @user.email_address, subject: t('mailers.reservation.notify_about_unmatched_reservation.subject'))
  end

  def notify_about_cancel_reservation(reservation_id)
    reservation = Reservation.where(id: reservation_id).first
    @user = reservation.user
    @schedule = reservation.schedule
    set_concierge_details
    mail(to: @user.email_address, subject: t('mailers.reservation.notify_about_cancel_reservation.subject'))
  end

  private
  def create_voucher
    @voucher = Voucher.new(description: "fifty_per_voucher", voucher_type: "percentage", amount: "50", start_date: Date.today.strftime("%Y-%m-%d"), end_date: "", quantity: "1", user_id: @user.id, gender: @user.gender, restriction: "all_users")
    @voucher.save
  end
end
