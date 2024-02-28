class VenueBookingNotification < ApplicationRecord
  belongs_to :venue_booking, dependent: :destroy
  belongs_to :matched_reservation
  belongs_to :reservation

  has_paper_trail

  after_create :generate_slug

  def notification_email
    self.reservation.user.user_info.email_address
  end

  def acknowledge!
    self.acknowledged = true
    self.save
  end

  private

  def generate_slug
    slug = Grouvly::Slug.generate(id.to_i + APP_CONFIG['start_id'])
    self.update_attributes({ slug: slug })
  end
end
