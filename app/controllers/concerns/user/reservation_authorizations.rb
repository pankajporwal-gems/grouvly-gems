module User::ReservationAuthorizations
  extend ActiveSupport::Concern

  included do
    before_filter :check_user_accepted, only: [:roll, :refund_amount]
    before_filter :check_reservation_is_valid, only: [:confirmed, :join]
    before_filter :check_lead_paid_reservation, only: [:join, :confirmed, :invite_wings]
  end

  private

  def check_reservation_is_valid
    render not_found if Chronic.parse('now') >= reservation.schedule
  end

  def check_user_accepted
    redirect_to root_url and return unless current_user.accepted?
  end

  def check_user_is_lead
    render not_found if current_user != reservation.user
  end

  def check_user_is_a_participant
    if !current_user == reservation.user && !reservation.wings.include?(current_user)
      render not_found
    end
  end

  def check_lead_paid_reservation
    render not_found unless lead.has_paid_reservation_on?(reservation.schedule)
  end

  def check_venue_notification_is_valid
    render not_found if param[:id].present
  end
end
