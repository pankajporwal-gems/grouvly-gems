class UserSerializer < ActiveModel::Serializer
  self.root = 'user'

  attributes :id, :age, :membership_type, :name, :slug

  has_one :user_info
end
