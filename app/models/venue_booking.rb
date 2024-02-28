class VenueBooking < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :venue
  belongs_to :matched_reservation

  has_many :venue_booking_transitions
  has_many :venue_booking_notifications

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, :history, to: :state_machine
  delegate :pending?, :accepted?, :rejected?, :cancelled?,
           :new!, :pend!, :accept!, :reject!, :cancel!, to: :venue_booking_state

  validates :schedule, presence: true

  after_create :generate_slug
  before_destroy :cancel!

  scope :active_bookings, -> { not_in_state(:cancelled) }

  has_paper_trail

  def state_machine
    @state_machine ||= StateMachines::VenueBooking.new(self, transition_class: VenueBookingTransition)
  end

  def venue_booking_state
    @venue_booking_state ||= VenueBookingState.new(self)
  end

  def self.transition_class
    VenueBookingTransition
  end

  def self.initial_state
    StateMachines::VenueBooking.initial_state
  end

  private

  def generate_slug
    slug = Grouvly::Slug.generate(id.to_i + APP_CONFIG['start_id'])
    self.update_attributes({ slug: slug })
  end
end
