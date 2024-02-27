class StateMachines::User
  include Statesman::Machine

  state :new, initial: true
  state :pending
  state :accepted
  state :rejected
  state :blocked
  state :wing
  state :deauthorized

  transition from: :new, to: [:pending, :wing, :deauthorized]
  transition from: :pending, to: [:wing, :accepted, :rejected, :deauthorized, :blocked]
  transition from: :deauthorized, to: [:pending, :accepted, :wing, :blocked]
  transition from: :accepted, to: [:blocked, :deauthorized]
  transition from: :wing, to: [:pending, :blocked, :deauthorized]
  transition from: :rejected, to: [:pending]

  after_transition(from: :new, to: :pending) do |user, transition|
    PendMembershipJob.perform_now(user.id)
  end

  after_transition(to: :accepted) do |user, transition|
    #AcceptMembershipJob.perform_now(user.id)
    #SendFirstReservationInvitationJob.set(wait: 1.minute).perform_now(user.id)
    SendFirstReservationInvitationJob.perform_now(user.id)
    UpdateFacebookFriendsJob.perform_now(user.id)

    if APP_CONFIG['referral_program_start_date'][user.location].present? &&
      user.changed_state_on?(:accepted) >= APP_CONFIG['referral_program_start_date'][user.location]

      ApplyReferralCreditJob.perform_now(user.id)
    end
  end
end
