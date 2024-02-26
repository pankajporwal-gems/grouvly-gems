class UserTransition < ApplicationRecord
  # serialize :metadata, Hash

  belongs_to :user, inverse_of: :user_transitions

  has_paper_trail

  def sort_key
    super.to_i
  end
end
