class UserTransition < ActiveRecord::Base
  # serialize :metadata, Hash

  belongs_to :user, inverse_of: :user_transitions

  has_paper_trail
end
