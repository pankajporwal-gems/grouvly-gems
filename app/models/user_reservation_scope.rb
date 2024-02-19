class UserReservationScope
  def initialize(user)
    @user ||= user
  end

  def absolute_query
    Reservation.active.joins('LEFT JOIN payments ON reservations.id = payments.reservation_id')
      .joins('LEFT JOIN cards ON cards.id = payments.card_id')
      .where(cards: { user_id: @user.id })
  end

  def valid_reservations
    absolute_query.where(payments: { status: 'success' })
  end

  def valid_and_pending_reservations
    Reservation.active.joins('LEFT JOIN payments ON reservations.id = payments.reservation_id')
      .joins('LEFT JOIN cards ON cards.id = payments.card_id').where("payments.status IN (?) and reservations.user_id = ? ", ['success', 'pending'], @user.id)
  end

  def all_latest_reservations
    valid_reservations.where('schedule >= ?', Chronic.parse('today')).where(user_id: @user.id)
  end

  def latest_reservation
    all_latest_reservations.first
  end

  def admin_all_latest_reservations
    valid_and_pending_reservations.where('schedule >= ?', Chronic.parse('today')).where(user_id: @user.id)
  end

  def admin_latest_reservation
    admin_all_latest_reservations.first
  end

  def last_reservation
    valid_reservations.where('schedule < ?', Chronic.parse('today')).where(user_id: @user.id).first
  end

  def has_paid_reservation_on?(schedule)
    return false if schedule.blank?
    reservations = valid_reservations.where(schedule: schedule)
    check_existing_reservation(reservations)
  end

  def has_panding_reservation_on?(schedule)
    return false if schedule.blank?
    reservations = valid_and_pending_reservations.where(schedule: schedule)
    check_existing_reservation(reservations)
  end

  def check_existing_reservation(reservations)
    if reservations.blank?
      false
    elsif reservations.first.user.id == @user.id || reservations.first.wings.map(&:id).include?(@user.id)
      reservations.first
    end
  end

  def total_reservation_amount
    valid_reservations.sum('payments.amount')
  end

  def total_reservations
    valid_reservations.count
  end

  def query_as
    absolute_query.where("(payments.status = 'success' AND payments.method = 'authorize') OR payments.method = 'capture'")
  end

  def total_reservations_as_lead
    query_as.where(reservations: { user_id: @user.id }).count
  end

  def total_reservations_as_wing
    query_as.where('reservations.user_id <> ?', @user.id).count
  end

  def total_reservations_completed
    valid_reservations.where('reservations.schedule > ?', Chronic.parse('today')).count
  end

  def total_matched_and_paid_reservations
    valid_reservations.where('reservations.id IN (SELECT first_reservation_id FROM matched_reservations) OR reservations.id IN (SELECT second_reservation_id FROM matched_reservations)')
      .where(payments: { method: 'capture' }).where(reservations: { user_id: @user.id }).uniq
  end
end
