class PaymentCollector
  attr_accessor :credit_card

  def initialize(user, payment)
    @payment ||= payment
    @user ||= user
  end

  def send(differnt_card=nil)
    if @user.is_first_time_payer?
      create_customer
    else
      create_payment_method(differnt_card)
    end
  end

  def update_credits
    if @payment.card.user.has_credits? && voucher.blank?
      credit_processor.deduct_credit('Payment', @payment.id)
    end
  end

  private

  def call_create_customer
    @call_create_customer ||= Grouvly::BraintreeApi.create_customer(@payment, @user)
    BRAINTREE_LOGGER.info("create_customer :: #{@call_create_customer.inspect}")
    @call_create_customer
  end

  def customer_credit_card
    call_create_customer.customer.credit_cards.first
  end

  def create_customer
    if call_create_customer
      @user.update_attribute(:customer_id, customer_credit_card.customer_id)
      @credit_card = Grouvly::BraintreeApi.add_credit_card(@user, customer_credit_card)
      BRAINTREE_LOGGER.info("Create payment_method :: #{@credit_card.inspect}")
      return true
    else
      @payment.update_attribute(:message, errors(call_create_customer))
      SendPaymentErrorJob.perform_now(@payment.id, @user.id)
      return false
    end
  end

  def call_create_payment_method
    @call_create_payment_method ||= Grouvly::BraintreeApi.create_payment_method(@user, @payment)
    BRAINTREE_LOGGER.info("Create payment_method :: #{@call_create_payment_method.inspect}")
    @call_create_payment_method
  end

  def payment_method
    if call_create_payment_method.success?
      call_create_payment_method.payment_method
    else
      nil
    end
  end

  def create_payment_method(differnt_card=nil)
    if @user.active_card.present? && differnt_card.blank?
      @credit_card = @user.active_card
    else
      if call_create_payment_method.success?
        @credit_card = Grouvly::BraintreeApi.add_credit_card(@user, payment_method)
        BRAINTREE_LOGGER.info("Create payment_method :: #{@credit_card.inspect}")
        return true
      else
        BRAINTREE_LOGGER.info("Create payment_method errors:: #{errors(call_create_payment_method)}")
        @payment.update_attribute(:message, errors(call_create_payment_method))
        SendPaymentErrorJob.perform_now(@payment.id, @user.id)
        return false
      end
    end
  end

  def errors(method)
    method.send(:errors).map(&:message).join('///')
  end

  def credit_processor
    @credit_processor ||= CreditProcessor.new(@payment.card.user)
  end

  def voucher
    @voucher ||= @payment.reservation.all_valid_payments.first.voucher
  end
end
