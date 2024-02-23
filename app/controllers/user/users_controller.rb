class User::UsersController < ApplicationController
  include User::UserAuthentication
  include User::UserTracking

  def dashboard
    @reservation = current_user.latest_reservation

    if @reservation
      redirect_to confirmed_user_reservation_url(@reservation.slug) and return
    elsif current_user.accepted?
      redirect_to new_user_reservation_url and return
    else
      check_user_blocked
      check_user_rejected
      check_user_deauthorized
      check_membership_info
      check_user_pending
      @user_decorator = UserDecorator.new(current_user)
    end
  end

  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end

  def show_referral_stats?
    current_user.accepted?
  end

  def updated_profile?
    true
    # return true if current_user.wing?
    # arr_records = %w(meet_new_people_ages hang_out_with typical_weekends native_place)
    # arr_records = arr_records + %w(neighborhoods) if current_user.location == "Hong Kong"
    # arr_records.all? { |attr| current_user.user_info[attr].present?}
  end

  helper_method :mobile_device?
  helper_method :show_referral_stats?
  helper_method :updated_profile?
end
