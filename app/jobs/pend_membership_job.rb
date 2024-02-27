class PendMembershipJob < ActiveJob::Base
  queue_as :mailers

  def perform(user_id)
    @user = User.find(user_id)
    # MembershipMailer.pend(@user).deliver_later
  end
end
