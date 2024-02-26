module User::MembershipAuthorizations
  extend ActiveSupport::Concern

  included do
    skip_before_filter :check_membership_info, only: [:new, :create]
    skip_before_filter :check_user_pending, only: [:finish, :invite, :edit, :update, :neighborhoods]
    skip_before_filter :check_user_rejected, only: [:finish, :invite, :edit, :update, :neighborhoods]

    before_filter :check_membership_info_exists, only: [:new, :create]
    before_filter :check_membership_rejected_or_pending, only: [:finish]
    before_filter :check_membership_wing, only: [:apply, :submit_application]
  end

  private

  def check_membership_info_exists
    redirect_to user_root_url and return if current_user.user_info.present?
    # redirect_to user_root_url and return unless current_user.new?
  end

  def check_membership_rejected_or_pending
    redirect_to user_root_url and return if current_user.accepted? || current_user.wing?
  end

  def check_membership_wing
    redirect_to user_root_url and return unless current_user.wing?
  end
end
