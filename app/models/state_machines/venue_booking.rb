class StateMachines::VenueBooking
  include Statesman::Machine

  state :new, initial: true
  state :pending
  state :accepted
  state :rejected
  state :cancelled

  transition from: :new, to: [:pending]
  transition from: :pending, to: [:accepted, :rejected, :cancelled]
  transition from: :accepted, to: [:cancelled]
  transition from: :rejected, to: [:cancelled]
end
