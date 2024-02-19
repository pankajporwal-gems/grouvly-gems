module LocationValidation
  extend ActiveSupport::Concern

  included do
    attr_accessor :other_neighborhood
    validates :location, inclusion: { in: APP_CONFIG['available_locations'] }
    validates :neighborhood, presence: true
    validate :validate_neighborhood
  end

  private

  def validate_neighborhood
    if self.neighborhood == I18n.t('terms.others') && self.other_neighborhood.blank?
      errors.add(:neighborhood, I18n.t('errors.messages.blank'))
    end
  end
end