class UserNote < ApplicationRecord
  belongs_to :user

  validates_presence_of :content

  has_paper_trail

  default_scope { order('created_at DESC') }
end
