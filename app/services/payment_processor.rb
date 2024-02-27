class PaymentProcessor
  def initialize(reservation)
    @reservation ||= reservation
  end

  def update_payments
    all_due_payments.each do |payment|
      if payment.card.token == 'free'
        payment.update_attribute(:amount, 0)
      elsif payment.card.user == lead && all_due_payments.size < wing_quantity.wing_quantity + 1
        count = 4 - all_due_payments.size
        amount = count * fee

        update_payment_amount(payment, amount)
      else
        update_payment_amount(payment, fee)
      end
    end
  end

  def capture_all_payments
    SIDEKIQ_LOGGER.info "capture_all_payments:: for reservation: #{@reservation.id}"
    if all_due_payments.size > 0
      errors = 0

      all_updated_due_payments.each do |payment|
        unless payment.card.token == 'free'
          capture_payment = Grouvly::BraintreeApi.capture_payment(payment)
          SIDEKIQ_LOGGER.info "capture_all_payments:: capture_payment: #{capture_payment.inspect}"
          if capture_payment.success?
            SIDEKIQ_LOGGER.info "capture_all_payments:: capture_payment_success: #{capture_payment.success?}"
            payment.transaction_id = capture_payment.transaction.id
            payment.status = 'success'
          elsif payment.method == 'authorize'
            SIDEKIQ_LOGGER.info "capture_all_payments:: authorize: #{payment.method == 'authorize'}"
            if capture_payment.transaction
              SIDEKIQ_LOGGER.info "capture_all_payments:: capture_payment_transaction: #{capture_payment.transaction.status}"
              payment.transaction_id = capture_payment.transaction.id
              payment.message = capture_payment.transaction.status
            else
              payment.message = errors(capture_payment)
              SIDEKIQ_LOGGER.info "capture_all_payments:: payment_error_messages: #{payment.message}"
            end
            payment.status = 'error'
            errors += 1
          end

          payment.method = 'capture'
          payment.save(validate: false)

          SIDEKIQ_LOGGER.info "capture_all_payments:: capture_successfully: #{payment.inspect}"

          SendPaymentReceiptJob.perform_now(payment.id) if capture_payment.success?
        else
          SIDEKIQ_LOGGER.info "capture_all_payments:: capture_successfully_for_free_card: #{payment.card.token}"
          payment.method = 'capture'
          payment.save(validate: false)
        end
      end

      return errors
    else
      SIDEKIQ_LOGGER.info "capture_all_payments:: ALL_PAID: true"
      return 'ALL_PAID'
    end
  end

  def refund_partial_amount
    SIDEKIQ_LOGGER.info "refund_partial_amount:: for reservation: #{@reservation.id}"
    errors = 0
    if is_refund_partial_amount?
      all_valid_payments.each do |payment|
        next unless payment.card.user == lead
        unless payment.card.token == 'free'
          if !is_refunded?(payment)
            payment_status = get_payment_status(payment)
            if payment_status == "settled" || payment_status == "settling"

                refund_amount = get_refund_amount

                SIDEKIQ_LOGGER.info "refund_partial_amount:: refund_amount: #{refund_amount}"

                lead_amount = payment.amount - refund_amount

                SIDEKIQ_LOGGER.info "refund_partial_amount:: remanning_lead_amount: #{lead_amount}"

                refund = Grouvly::BraintreeApi.refund_amount(payment, refund_amount)

                SIDEKIQ_LOGGER.info "refund_partial_amount:: braintree_refund_response: #{refund.inspect}"

                refund_obj = Refund.new(reservation_id: @reservation.id, card_id: payment.card.id, amount: refund_amount, currency: payment.currency, transaction_id: refund.transaction.id, payment_id: payment.id)

                if refund.success?
                  payment.update_attribute('amount', lead_amount)
                  refund_obj.status = "success"
                else
                  refund_obj.status = "error"
                  refund_obj.messages = refund.transaction.status
                  errors += 1
                end
                refund_obj.save
                SIDEKIQ_LOGGER.info "refund_partial_amount:: refund: #{refund_obj.inspect}"
            else
              errors += 1
            end
          else
            SIDEKIQ_LOGGER.info "refund_partial_amount:: Already refunded amount: #{payment.inspect}"
          end
        else
          SIDEKIQ_LOGGER.info "refund_partial_amount:: with_free_token: #{payment.card.token}"
        end
      end
    else
      SIDEKIQ_LOGGER.info "refund_partial_amount:: all_refunded: true"
    end
    errors
  end

  def refund_total_amount
    status = false
    SIDEKIQ_LOGGER.info "refund_total_amount:: for reservation: #{@reservation.id}"
    unless all_valid_payments.size == 0 && @reservation.payments.size == pending_payments.size
      all_valid_payments.each do |payment|
        unless payment.card.token == 'free'
          if !is_refunded?(payment)
            payment_status = get_payment_status(payment)
            if payment_status == "settled" || payment_status == "settling"
              refund = Grouvly::BraintreeApi.refund_amount(payment, payment.amount.to_f)
              status = check_refund_status(payment, refund, payment.amount.to_f)
            elsif payment_status == "submitted_for_settlement" || payment_status == "authorized"
              refund = Grouvly::BraintreeApi.void_transaction(payment)
              status = check_refund_status(payment, refund, payment.amount.to_f)
            end
          else
            SIDEKIQ_LOGGER.info "refund_total_amount:: Already refunded => reservation_id: #{@reservation.id}, payment_id: #{payment.id}"
            status = true
          end
        else
          SIDEKIQ_LOGGER.info "refund_partial_amount:: with_free_token: #{payment.card.token}, payment_id: #{payment.id}"
          status = true
        end
      end
    else
      SIDEKIQ_LOGGER.info "refund_total_amount:: for reservation: #{@reservation.id}, pending_payments: #{pending_payments.inspect}"
      status = true
    end
    status
  end

  def refund_amount_for_member(member_id, refund_amount)
    status = false
    error_type = ""
    user = User.where(id: member_id).first
    SIDEKIQ_LOGGER.info "refund_amount_for_member:: for reservation: #{@reservation.id}, user: #{user.id}"
    all_valid_payments.each do |payment|
      next unless payment.card.user == user
      if refund_amount.to_f <= payment.amount.to_f
        payment_status = get_payment_status(payment)
        if payment_status == "settled" || payment_status == "settling"
          refund = Grouvly::BraintreeApi.refund_amount(payment, refund_amount.to_f)
          status = check_refund_status(payment, refund, refund_amount.to_f)
        else
          error_type = "not_settled"
          SIDEKIQ_LOGGER.info "refund_amount_for_member:: for reservation: #{@reservation.id}, user: #{user.id}, payment_status: #{payment_status}"
        end
      else
        error_type = "not_less_then"
        SIDEKIQ_LOGGER.info "refund_amount_for_member:: for reservation: #{@reservation.id}, user: #{user.id}, refund_amount: refund_amount_must_be_less_then_or_equal_to_transaction_amount"
      end
    end
    return status, error_type
  end


  private

  def check_refund_status(payment, refund, refund_amount)
    refund_obj = Refund.new(reservation_id: @reservation.id, card_id: payment.card.id, amount: refund_amount, currency: payment.currency, transaction_id: refund.transaction.id, payment_id: payment.id)

    if refund.success?
      refund_obj.status = "success"
      remanning_amount = payment.amount.to_f - refund_amount
      payment.update_attribute('amount', remanning_amount)
      SIDEKIQ_LOGGER.info "refund_total_amount:: refund_ssucess: #{refund.success?}, payment: #{payment.id}"
    else
      refund_obj.status = "error"
      refund_obj.messages = refund.transaction.status
       SIDEKIQ_LOGGER.info "refund_total_amount:: refund_error: #{refund.transaction.status}, payment: #{payment.id}"
    end
    refund_obj.save
    SIDEKIQ_LOGGER.info "refund_total_amount:: refund_obj: #{refund_obj.inspect}, payment: #{payment.id}"
    status = refund.success?
  end

  def pending_payments
    @reservation.pending_payments
  end

  def all_valid_payments
    @all_valid_payments ||= @reservation.all_valid_payments
  end

  def all_due_payments
    @all_due_payments ||= @reservation.all_due_payments
  end

  def all_updated_due_payments
    if all_due_payments.size <  @reservation.wing_quantity.to_i + 1
      all_due_payments.each do |payment|
        if payment.card.user == lead
          if payment.card.token == 'free'
            payment.update_attribute(:amount, 0)
          else
            amount = get_updated_amount(payment.amount.to_i)
            payment.update_attribute('amount', amount)
          end
        end
      end
    end
    all_due_payments
  end

  def get_refund_amount
    case @reservation.wings.count
    when 1
      fee
    when 2
      fee*2
    end
  end

  def update_payment_status(payment)
    payment_obj = Grouvly::BraintreeApi.find_transaction(payment)
    payment.update_attribute('transaction_status', payment_obj.status)
    payment_obj
  end

  def get_payment_status(payment)
    payment_obj = update_payment_status(payment)
    payment_obj.status
  end

  def is_refunded?(payment)
    payment.refunds.latest.status == "success"  if payment.refunds.present?
  end

  def is_refund_partial_amount?
    payment_count = all_valid_payments.size
    payment_count > 1 && payment_count <= @reservation.wing_quantity + 1
  end

  def get_updated_amount(amount)
    if @reservation.wings.count < @reservation.wing_quantity
      pending_wing_count= @reservation.wing_quantity - @reservation.wings.count
      amount + fee*pending_wing_count
    else
      amount
    end
  end

  def lead
    @lead ||= @reservation.user
  end

  def fee
    @fee = APP_CONFIG['fee'][lead.location][lead.gender].to_i
    @fee = (@fee + APP_CONFIG['express_fee'][lead.location].to_i)  if @reservation.last_minute_booking
    @fee
  end

  def update_payment_amount(payment, amount)
    @voucher ||= payment.reservation.all_valid_payments.first.voucher

    if @voucher.present?
      if amount > fee
        counter = amount / fee
        amount = amount - (@voucher.amount * counter)
      else
        amount = amount - @voucher.amount
      end
    elsif payment.credit.present?
      amount = amount - payment.credit.amount if payment.credit.action == 'deduct'
    end

    payment.update_attribute(:amount, amount) if amount.present? && payment.amount != amount
  end

  def errors(method)
    method.send(:errors).map(&:message).join('///')
  end
end
