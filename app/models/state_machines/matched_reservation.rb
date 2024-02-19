class StateMachines::MatchedReservation
  include Statesman::Machine

  state :new, initial: true
  state :unmatched
  state :completed

  transition from: :new, to: [:new, :unmatched, :completed]
end
