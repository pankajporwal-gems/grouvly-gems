class Payment < ApplicationRecord
  before_validation :skip_reservation_validation
  before_validation :check_card
  before_destroy :delete_credit

  has_one :credit, as: :actor, dependent: :destroy
  belongs_to :reservation
  belongs_to :card
  belongs_to :voucher
  has_many :refunds, dependent: :destroy

  attr_accessor :name, :card_number, :cvv, :expiry_month, :expiry_year, :payment_method_nonce, :voucher_code,
    :user

  validates :name, presence: true
  validates_associated :reservation
  validates_associated :card
  validate :voucher_code_valid

  accepts_nested_attributes_for :reservation

  scope :successful, -> { where(status: 'success') }

  scope :authorized, -> { where(status: 'authorize') }

  scope :captured, -> { where(method: 'capture') }

  scope :all_due_payments_for_reservation, -> (reservation) {
    joins(:reservation)
      .where(payments: { reservation_id: reservation.id })
      .where("((payments.status = 'success' AND payments.method = 'authorize') OR (payments.status = 'error' AND payments.method = 'capture'))")
  }

  scope :all_valid_payments, -> (reservation) {
    joins(:reservation)
      .where(payments: { reservation_id: reservation.id })
      .where("((payments.status = 'success' AND payments.method = 'authorize') OR (payments.method IN ('capture', 'refund')))")
  }

  scope :pending_payments, -> (reservation) {
    joins(:reservation)
      .where(payments: { reservation_id: reservation.id })
      .where("(payments.status = 'pending' AND payments.method = 'authorize')")
  }

  has_paper_trail

  def amount_in_usd
    self.amount * APP_CONFIG['fee_exchange_rate'][currency]['USD']
  end

  private

  def user_voucher_decorator
    @user_voucher_decorator ||= UserVoucherDecorator.new(reservation.user, voucher)
  end

  def skip_reservation_validation
    reservation.skip_validation = true unless reservation.id.blank?
  end

  def check_card
    if voucher_code.present? && !user.has_credits?
      voucher = Voucher.where(slug: voucher_code).first

      self.voucher = voucher if voucher.present?
    end

    if reservation.user != user && reservation.all_valid_payments.any?
      if reservation.all_valid_payments.first.voucher.present?
        self.voucher = reservation.all_valid_payments.first.voucher
      end
    end

    if self.voucher.present?
      if user_voucher_decorator.fee == 0
        card = user.cards.where(token: 'free').first

        if card.blank?
          card = Card.create!(user: user, token: 'free', bin: 4111, card_type: 'visa', last_digits: 1111)
        end

        self.card = card
        self.name = user.first_name
        self.status = 'success'
      end

      self.voucher = nil if reservation.user != user
    end
  end

  def voucher_code_valid
    if voucher.present? && reservation.user == user
      if user.has_credits?
        errors.add(:voucher_code, I18n.t('user.payments.errors.cannot_be_used'))
      else
        unless voucher.is_valid?(user)
          errors.add(:voucher_code, I18n.t('user.payments.errors.is_invalid'))
        end
      end
    end
  end

  def delete_credit
    if  self.card.present?
      credits = self.card.user.credits.where({ action: 'deduct', activity: 'payment', actor_id: id, actor_type: 'Payment'})

      credits.each do |credit|
        credit.destroy
      end
    end
  end
end
