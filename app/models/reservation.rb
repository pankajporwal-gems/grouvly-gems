class Reservation < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  after_create :generate_slug

  belongs_to :user
  has_many :matched_reservations, foreign_key: 'first_reservation_id', dependent: :destroy
  has_many :inverse_matched_reservations, class_name: 'MatchedReservation', foreign_key: 'second_reservation_id', dependent: :destroy
  has_many :venue_booking_notifications
  has_many :payments, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :unmatched_reservation_histories, dependent: :destroy
  has_many :reservation_transitions, dependent: :destroy

  attr_accessor :skip_validation

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, :history, to: :state_machine
  delegate :new?, :payment_entered?, :pending_payment?, :cancelled?, :new!, :enter_payment!, :pending_peyment!, :cancel!, to: :reservation_state
  delegate :is_full?, :all_valid_payments, :pending_payments, :all_due_payments, :wings, :recently_booked?, :total_amount_paid, :available_members,
    to: :reservation_payment_scope

  validates :schedule, has_paid_reservation: true, schedule: true, unless: :skip_validation
  validates_associated :user

  scope :default, -> {
    joins(user: :user_info).uniq
  }

  scope :find_by_location, -> (location) {
    default.where(user_infos: { location: location })
  }

  scope :find_by_schedule, -> (schedule) {
    default.where(reservations: { schedule: schedule })
  }

  scope :find_by_location_gender_and_schedule, -> (reservation) {
    find_by_location(reservation.user.location)
      .find_by_schedule(reservation.schedule)
      .where(user_infos: { gender: reservation.user.gender_to_match })
  }

  scope :only_male, -> {
    default.where(user_infos: { gender: 'male' })
  }

  scope :only_female, -> {
    default.where(user_infos: { gender: 'female' })
  }

  scope :default_match, -> {
    in_state(:payment_entered, :pending_payment)
      .joins("LEFT OUTER JOIN matched_reservations matched_reservations1 ON matched_reservations1.first_reservation_id = reservations.id")
      .joins("LEFT OUTER JOIN matched_reservation_transitions transition11 ON transition11.matched_reservation_id = matched_reservations1.id")
      .joins("LEFT OUTER JOIN matched_reservation_transitions transition12 ON transition12.matched_reservation_id = matched_reservations1.id AND transition12.sort_key > transition11.sort_key")
      .joins("LEFT OUTER JOIN matched_reservations matched_reservations2 ON matched_reservations2.second_reservation_id = reservations.id")
      .joins("LEFT OUTER JOIN matched_reservation_transitions transition21 ON transition21.matched_reservation_id = matched_reservations2.id")
      .joins("LEFT OUTER JOIN matched_reservation_transitions transition22 ON transition22.matched_reservation_id = matched_reservations2.id AND transition22.sort_key > transition21.sort_key")
  }

  scope :matched, -> {
    default_match
      .where("(((transition11.to_state IN ('new', 'completed') OR transition11.to_state IS NULL) AND transition12.id IS NULL) AND matched_reservations1.id IS NOT NULL) OR (((transition21.to_state IN ('new', 'completed') OR transition21.to_state IS NULL) AND transition22.id IS NULL) AND matched_reservations2.id IS NOT NULL)")
  }

  scope :unmatched, -> {
    default_match
      .where("((transition11.to_state IN ('unmatched') AND transition11.to_state IS NOT NULL) AND transition12.id IS NULL) OR ((transition21.to_state IN ('unmatched') AND transition21.to_state IS NOT NULL) AND transition22.id IS NULL) OR (matched_reservations1.id IS NULL AND matched_reservations2.id IS NULL)")
      .where("reservations.id NOT IN (SELECT first_reservation_id FROM matched_reservations matched_reservations3 LEFT OUTER JOIN matched_reservation_transitions transition31 ON transition31.matched_reservation_id = matched_reservations3.id LEFT OUTER JOIN matched_reservation_transitions transition32 ON transition32.matched_reservation_id = matched_reservations3.id AND transition32.sort_key > transition31.sort_key WHERE (transition31.to_state IN ('new', 'completed') OR transition31.to_state IS NULL) AND transition32.id IS NULL AND matched_reservations3.first_reservation_id = reservations.id ORDER BY matched_reservations3.created_at DESC LIMIT 1)")
      .where("reservations.id NOT IN (SELECT second_reservation_id FROM matched_reservations matched_reservations4 LEFT OUTER JOIN matched_reservation_transitions transition41 ON transition41.matched_reservation_id = matched_reservations4.id LEFT OUTER JOIN matched_reservation_transitions transition42 ON transition42.matched_reservation_id = matched_reservations4.id AND transition42.sort_key > transition41.sort_key WHERE (transition41.to_state IN ('new', 'completed') OR transition41.to_state IS NULL) AND transition42.id IS NULL AND matched_reservations4.second_reservation_id = reservations.id ORDER BY matched_reservations4.created_at DESC LIMIT 1)")
  }

  scope :new_matches, -> {
    default_match
      .where("(((transition11.to_state IN ('new') OR transition11.to_state IS NULL) AND transition12.id IS NULL) AND matched_reservations1.id IS NOT NULL) OR (((transition21.to_state IN ('new') OR transition21.to_state IS NULL) AND transition22.id IS NULL) AND matched_reservations2.id IS NOT NULL)")
  }

  scope :upcoming, -> { where("reservations.schedule >= ?", Chronic.parse('today at 8PM'))
  }

  scope :active, -> { in_state(:payment_entered, :pending_payment, :new)}

  scope :auto_rolled, -> {where(is_roll: true)}

  has_paper_trail

  def self.transition_class
    ReservationTransition
  end

  def self.initial_state
    StateMachines::Reservation.initial_state
  end

  def roll_count
    self.unmatched_reservation_histories.count
  end

  def state_machine
    @state_machine ||= StateMachines::Reservation.new(self, transition_class: ReservationTransition)
  end

  def is_matched?
    matched_reservations.in_state(:new, :completed).any? || inverse_matched_reservations.in_state(:new, :completed).any?
  end

  def wing_quantity
    super.to_i
  end

  def reservation_emails
    reservations = matched_reservations.present? ? matched_reservations : inverse_matched_reservations
    emails = []
    emails = [reservations.last.first_reservation.user.email_address + "," + reservations.last.second_reservation.user.email_address] if reservations.present?
    emails.join(", ")
  end

  def reservation_wing_emails
    emails = []
    self.wings.each do |wing|
      emails << wing.email_address
    end
    emails.join(", ")
  end

  def state_string
    if all_due_payments.any?
      'booked'
    else
      'completed'
    end
  end

  def matched_reservation
    matched_reservations.in_state(:new, :completed).first
  end

  def inverse_matched_reservation
    inverse_matched_reservations.in_state(:new, :completed).first
  end

  def complete_match
    if matched_reservation.blank?
      other_status = inverse_matched_reservation.first_reservation.all_valid_payments.select { |s| s.status != 'success' }
      inverse_matched_reservation.complete! unless other_status.any?
    else
      other_status = matched_reservation.second_reservation.all_valid_payments.select { |s| s.status != 'success' }
      matched_reservation.complete! unless other_status.any?
    end
  end

  def schedule
    super.to_datetime
  end

  private

  def generate_slug
    slug = Grouvly::Slug.generate(id.to_i + APP_CONFIG['start_id']) + SecureRandom.urlsafe_base64(2)
    self.update_attributes({ slug: slug })
  end

  def reservation_state
    @reservation_state ||= ReservationState.new(self)
  end

  def reservation_payment_scope
    @reservation_payment_scope ||= ReservationPaymentScope.new(self)
  end
end
