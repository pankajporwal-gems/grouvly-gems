class Voucher < ApplicationRecord
  after_create :generate_slug

  belongs_to :user
  has_many :payments

  has_paper_trail

  validates :description, presence: true
  validates :voucher_type, inclusion: { in: %w(cash percentage) }
  validates :amount, numericality: { greater_than: 0 }
  validates :start_date, date: { allow_blank: true }
  validates :end_date, date: { allow_blank: true, after: :start_date,  }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :gender, inclusion: { in: %w(male female) }, allow_blank: true
  validates_associated :user, allow_blank: true
  validates :restriction, inclusion: { in: %w(all_users all_members not_member) }, allow_blank: true

  def is_valid?(user)
    return false if user.has_already_relunch_redeemed_voucher?
    return false if user.has_redeemed_voucher?(self)

    return false if self.start_date.present? && DateTime.now.to_date < self.start_date

    return false if self.end_date.present? && DateTime.now.to_date > self.end_date

    if self.user.present?
      return false if self.user != user
    else
      if self.quantity.present? && self.quantity == 0
        return false
      elsif self.gender.present? && user.gender != self.gender
        return false
      elsif self.restriction.present?
        if (self.restriction == 'all_members' && !user.accepted?) ||
          (self.restriction == 'not_member' && user.accepted?)
          return false
        end
      end
    end

    return true
  end

  def self.create_voucher(user)
    created_voucher = Voucher.where("user_id = ? AND description = ?", user.id, "Relaunch voucher")
    if created_voucher.present?
      created_voucher.last
    else
      start_date = DateTime.now.in_time_zone
      end_date = DateTime.now.in_time_zone.end_of_month + 20.days
      voucher = Voucher.new(description: "Relaunch voucher", voucher_type: "percentage", amount: 50.0, start_date: start_date, end_date: end_date, quantity: 1, user_id: user.id, gender: user.gender, restriction: APP_CONFIG['voucher_restrictions'].first )
      voucher if voucher.save
    end
  end

  private

  def generate_slug
    slug = Grouvly::Slug.generate(id + APP_CONFIG['start_id']) + SecureRandom.urlsafe_base64(1)
    self.update_attributes({ slug: slug })
  end
end
