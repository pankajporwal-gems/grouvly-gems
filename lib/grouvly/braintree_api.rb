require 'braintree'

module Grouvly
  module BraintreeApi
    extend self

    def generate_client_token(user)
      gateway = Braintree::Gateway.new(:environment => :sandbox, :merchant_id => ENV["BRAINTREE_MERCHANT_ID"], :public_key => ENV["BRAINTREE_PUBLIC_KEY"], :private_key => ENV["BRAINTREE_PRIVATE_KEY"])
      if user.customer_id
        Braintree::ClientToken.generate(customer_id: user.customer_id)
      else
        Braintree::ClientToken.generate
      end
    end

    def create_customer(payment, user)
      @payment = payment

      Braintree::Customer.create(
        first_name: first_name,
        last_name: last_name,
        email: user.email_address,
        payment_method_nonce: payment.payment_method_nonce,
        credit_card: {
          options: {
            verify_card: true
          }
        }
      )
    end

    def create_payment_method(user, payment)
      Braintree::PaymentMethod.create(
        customer_id: user.customer_id,
        cardholder_name: payment.name,
        payment_method_nonce: payment.payment_method_nonce,
        options: {
          verify_card: true
        }
      )
    end

    def find_payment_method(card)
      begin
        Braintree::PaymentMethod.find(card.token)
      rescue
        false
      end
    end

    def find_transaction(payment)
      @payment = payment
      Braintree::Transaction.find(transaction_token)
    end

    def void_transaction(payment)
      @payment = payment
      Braintree::Transaction.void(transaction_token)
    end

    def delete_payment_method(card)
      begin
        Braintree::PaymentMethod.delete(card.token)
      rescue
        false
      end
    end

    def add_credit_card(user, card)
      credit_card = user.cards.where(bin: card.bin, card_type: card.card_type, last_digits: card.last_4).first

      unless credit_card.blank? && !find_payment_method(credit_card)
        delete_payment_method(card)
        credit_card.touch
      else
        credit_card = build_card(user, card)
        credit_card.save!
      end

      return credit_card
    end

    def capture_payment(payment)
      @payment = payment
      Braintree::Transaction.sale(
        amount: payment.amount,
        payment_method_token: payment_token,
        merchant_account_id: ENV["MERCHANT_ACCOUNT_ID"],
        options: {
          submit_for_settlement: true
        }
      )
    end

    def refund_amount(payment, amount)
      @payment = payment
      Braintree::Transaction.refund(transaction_token, amount)
    end

    private

    def first_name
      name = @payment.name.split(' ')

      if name.length > 2
        name.values_at(0,1).join(' ')
      else
        name[0]
      end
    end

    def last_name
      @payment.name.sub(first_name, '')
    end

    def payment_card
      @payment.card
    end

    def transaction_token
      @payment.transaction_id
    end

    def payment_token
      payment_card.token
    end

    def payment_merchant
      APP_CONFIG['braintree_merchant_accounts'][payment_card.user.location]
    end

    def build_card(user, card)
      user.cards.new({ token: card.token, bin: card.bin, card_type: card.card_type, last_digits: card.last_4 })
    end
  end
end
