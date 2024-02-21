class MembershipMailer < BaseMailer
  def pend(user)
    @user = user
    @gender_preference = @user.gender_to_match == 'female' ? t('terms.girls') : t('terms.guys')

    set_concierge_details

    # mail(to: @user.email_address, subject: "#{t('mailers.membership.pend.subject')}")
  end

  def accept(user)
    @user = user

    set_concierge_details

    # mail(to: @user.email_address, subject: "#{t('mailers.membership.accept.subject')}")
  end
end
