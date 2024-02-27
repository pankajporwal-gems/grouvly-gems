class AcceptMembershipJob < ActiveJob::Base
  queue_as :mailers

  def perform(user_id)
    @user = User.find(user_id)
    # MembershipMailer.accept(@user).deliver_later
  end
end
