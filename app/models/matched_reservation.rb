class MatchedReservation < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :first_reservation, class_name: 'Reservation'
  belongs_to :second_reservation, class_name: 'Reservation'
  has_many :venue_bookings, dependent: :destroy
  has_many :venue_booking_notifications, dependent: :destroy
  has_many :matched_reservation_transitions, dependent: :destroy

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, :history, to: :state_machine
  delegate :new?, :unmatched?, :completed?, :new!, :unmatch!, :complete!, to: :matched_reservation_state
  delegate :latest_booking, :latest_accepted_booking, to: :venue_scope

  has_paper_trail

  scope :default, -> {
    includes(:first_reservation, :second_reservation)
      .joins(first_reservation: { user: :user_info })
  }

  scope :find_by_location, -> (location) {
    default.where(user_infos: { location: location })
  }

  scope :find_by_schedule, -> (schedule) {
    default.where(matched_reservations: { schedule: schedule })
  }

  scope :upcoming, -> { where("matched_reservations.schedule >= ?", Chronic.parse('today at 8PM'))
  }

  def self.transition_class
    MatchedReservationTransition
  end

  def self.initial_state
    StateMachines::MatchedReservation.initial_state
  end

  def state_machine
    @state_machine ||= StateMachines::MatchedReservation.new(self, transition_class: MatchedReservationTransition)
  end

  def schedule
    super.to_datetime
  end

  private

  def matched_reservation_state
    @matched_reservation_state ||= MatchedReservationState.new(self)
  end

  def venue_scope
    @venue_booking_scope ||= MatchedReservationVenueScope.new(self)
  end
end
