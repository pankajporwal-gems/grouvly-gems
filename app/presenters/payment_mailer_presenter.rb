class PaymentMailerPresenter
  delegate :lead, :reservation, :fee, to: :new_payment_presenter

  def initialize(payment)
    @payment ||= payment
  end

  def slug
    @slug ||= reservation.slug
  end

  def user
    @user ||= @payment.card.user
  end

  def date
    @date ||= schedule.strftime('%A, %B %d') + ' ' + schedule.strftime('%l:%M %p')
  end

  def only_date
    @only_date ||= schedule.strftime('%A, %B %d')
  end

  def only_time
    @only_time ||= schedule.strftime('%l:%M %p')
  end

  def previous_date
    @previous_date ||= (schedule - 1.day).strftime('%A, %B %d')
  end

  def amount
    @amount ||= @payment.amount
  end

  def currency
    @currency ||= @payment.currency
  end

  def transaction_id
    @transaction_id ||= @payment.transaction_id
  end

  def first_name
    @first_name ||= user.first_name
  end

  def quantity
    @quantity ||= amount / fee.to_i
  end

  private

  def schedule
    reservation.schedule
  end

  def new_payment_presenter
    @new_payment_presenter ||= NewPaymentPresenter.new(@payment)
  end
end
