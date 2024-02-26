class Venue < ApplicationRecord
  include LocationValidation

  has_many :venue_bookings, dependent: :destroy

  store_accessor :booking_availability, Date::DAYNAMES.map { |day| day.downcase.to_sym }

  validates :name, :venue_type, :capacity,
            :owner_name, :owner_email, :owner_phone, :owner_phone,
            :manager_name, :manager_email, :manager_phone,
            :map_link, :directions, presence: true

  default_scope { where(deleted_at: nil) }

  scope :available_for_booking, -> (schedule) {
    where('venues.id NOT IN (SELECT venues.id FROM venues
                              JOIN venue_bookings ON venue_bookings.venue_id = venues.id
                              LEFT JOIN venue_booking_transitions ON venue_booking_transitions.venue_booking_id = venue_bookings.id AND venue_booking_transitions.to_state = \'accepted\'
                              WHERE venue_bookings.schedule = ?
                              GROUP BY venues.id
                              HAVING COUNT(venue_bookings.id) >= venues.capacity)', schedule)
  }

  has_paper_trail

  def destroy
    self.update_attribute :deleted_at, Time.now.utc
  end
end