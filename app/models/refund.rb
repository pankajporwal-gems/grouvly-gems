class Refund < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :card
  belongs_to :payment
  scope :latest, -> { order('created_at').first}
end