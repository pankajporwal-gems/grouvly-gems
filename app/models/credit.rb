class Credit < ApplicationRecord
  belongs_to :user
  belongs_to :actor, polymorphic: true
end
