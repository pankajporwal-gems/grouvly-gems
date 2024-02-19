class ReservationSerializer < ActiveModel::Serializer
  self.root = 'reservation'

  attributes :id, :slug, :current_state, :roll_count, :wing_quantity

  has_one :user
  has_many :wings
end
