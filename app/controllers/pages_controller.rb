class PagesController < ApplicationController
  include User::UserAuthentication
  include User::UserTracking

  skip_before_filter :verify_authenticity_token, only: :index
  skip_before_filter :authenticate_user
  skip_before_filter :check_user_blocked
  skip_before_filter :check_user_rejected
  skip_before_filter :check_user_deauthorized
  skip_before_filter :check_membership_info
  skip_before_filter :check_user_pending

  def index
    if current_user
      redirect_to user_root_url and return
    elsif current_admin
      redirect_to admin_root_url and return
    end

    track_page(PAGE_HOME)

    render layout: 'application_two'
  end

  def contact_us
    @available_message_about = APP_CONFIG['available_message_about']

    track_page(PAGE_CONTACT_US)

    send_inquiry
    render layout: 'application_two'
  end

  def bars_and_venues
    track_page(PAGE_VENUES)

    send_inquiry
    render layout: 'application_two'
  end

  def join
    @presenter = JoinPagePresenter.new(referrer)
    @hide_referrer_at_top = true
    set_referrer_session
    redirect_to root_url if referrer.blank?
  end

  def about_us
    track_page(PAGE_ABOUT_US)
    render layout: 'application_two'
  end

  def faq
    track_page(PAGE_FAQ)
    render layout: 'application_two'
  end

  def how_it_works
    track_page(PAGE_HOW_IT_WORKS)
    render layout: 'application_two'
  end

  def press
    track_page(PAGE_PRESS)
  end

  def privacy_policy
    track_page(PAGE_PRIVACY)
    render layout: 'application_two'
  end

  def terms_of_service
    track_page(PAGE_TOS)
    render layout: 'application_two'
  end

  def why_facebook
    track_page(PAGE_FACEBOOK_FAILURE)
    render layout: 'application_two'
  end

  private

  def set_referrer_session
    session[:grouvly_referral_url] = request.original_url if current_user.blank?
  end

  def inquiry_params
    params.require(:inquiry).permit(:name, :email_address, :phone, :what_is_message_about, :message, :website)
  end

  def send_inquiry
    if params[:commit] && params[:commit] == I18n.t('pages.contact_us.send')
      @inquiry = Inquiry.new(inquiry_params)

      if @inquiry.valid?
        flash.now[:notice] = I18n.t('pages.contact_us.your_inquiry_has_been_submitted')
        SendInquiryJob.perform_now(JSON.parse(@inquiry.to_json).to_hash)
        @inquiry = Inquiry.new
      end
    else
      @inquiry = Inquiry.new
    end
  end
end
