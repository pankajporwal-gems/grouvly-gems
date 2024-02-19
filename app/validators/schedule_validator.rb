class ScheduleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !Grouvly::ReservationDate.is_schedule_valid?(value, record.user_type)
      error = I18n.t('user.reservations.errors.messages.you_have_not_chosen_a_valid_schedule')
      record.errors.add(attribute, error)
    end
  end
end
