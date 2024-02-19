class StateMachines::Reservation
  include Statesman::Machine

  state :new, initial: true
  state :payment_entered
  state :cancelled
  state :pending_payment

  transition from: :new, to: [:payment_entered]
  transition from: :payment_entered, to: [:cancelled]
  transition from: :new, to: [:pending_payment]
  transition from: :pending_payment, to: [:payment_entered]
  transition from: :pending_payment, to: [:cancelled]
end
