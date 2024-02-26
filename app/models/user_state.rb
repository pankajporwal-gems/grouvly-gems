class UserState
  def initialize(user)
    @user ||= user
  end

  def new?
    @user.current_state == 'new'
  end

  def pending?
    @user.current_state == 'pending'
  end

  def accepted?
    @user.current_state == 'accepted'
  end

  def rejected?
    @user.current_state == 'rejected'
  end

  def wing?
    @user.current_state == 'wing'
  end

  def blocked?
    @user.current_state == 'blocked'
  end

  def deauthorized?
    @user.current_state == 'deauthorized'
  end

  def new!
    @user.transition_to(:new, { occured_on: Time.now })
  end

  def pend!
    @user.transition_to(:pending, { occured_on: Time.now })
  end

  def wing!
    @user.transition_to(:wing, { occured_on: Time.now }.to_json)
  end

  def accept!(performer)
    @user.transition_to(:accepted, { occured_on: Time.now, performed_by: performer })
  end

  def reject!(performer, reason)
    @user.transition_to(:rejected, { occured_on: Time.now, performed_by: performer, reason: reason })
  end

  def deauthorized!
    @user.transition_to(:deauthorized, { occured_on: Time.now })
  end

  def changed_state_on?(state)
    @user.history.where("user_transitions.to_state = ?", state).pluck('created_at').first
  end
end
