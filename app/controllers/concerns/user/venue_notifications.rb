module User::VenueNotifications
  extend ActiveSupport::Concern

  included do
    before_filter :check_venue_notification_is_valid, only: :confirm_venue_notification
  end

  def venue_notification
    if params[:id]
      VenueBookingNotification.where(slug: params[:id]).first
    end
  end

  private

  def check_venue_notification_is_valid
    render not_found unless params[:id].present?
  end
end
