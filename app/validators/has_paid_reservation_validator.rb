class HasPaidReservationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.user.has_panding_reservation_on?(value)
      error = I18n.t('user.reservations.errors.messages.already_have_a_reservation',
        { reservation_date: record.schedule.strftime('%A, %B %d') })
      record.errors.add(attribute, error)
    else
       if record.user.has_paid_reservation_on?(value)
        error = I18n.t('user.reservations.errors.messages.already_have_a_reservation',
          { reservation_date: record.schedule.strftime('%A, %B %d') })
        record.errors.add(attribute, error)
      end
    end
  end
end
