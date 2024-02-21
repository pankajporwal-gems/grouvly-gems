class SessionsController < ApplicationController
  include User::UserTracking

  def authenticate_admin
    reset_session
    set_admin_session

    if current_admin
      redirect_to admin_root_url
    else
      reset_session
      redirect_to root_url
    end
  end

  def new

  end

  def create
    user = User.find_by(uid: params[:user][:uid])
    if user.present?
      reset_session
      session[:user_id] = user.id
      increase_session_count(user)
      # To keep users logged in
      # cookies.permanent[:oauth_uid] = user.uid

      # index = :join_grouvly_url
      redirect_to user_root_url
      # session[index] = url if url.present? && session_index == index
    else
      flash[:alert] = "User Not Found"
      render :new
    end

    # session_index, url = set_referral_tracking_url
    # return_to = session[:return_to]
    # login_user(session_index, url)

    # if return_to
    #   track_event(EVENT_LOGGED_IN)
    #   set_flash
    #   redirect_to return_to
    # elsif current_user.user_info.blank?
    #   set_flash
    #   redirect_to new_user_membership_url
    # else
    #   track_event(EVENT_LOGGED_IN)
    #   render_page_of_logged_in_user
    # end
  end

  def destroy
    track_event(EVENT_LOGGED_OUT)
    reset_session
    # Clear cookie used to keep users logged in
    cookies.delete(:oauth_uid)

    redirect_to root_url
  end

  private

  def build_user
    @user_creator ||= UserCreator.new(env['omniauth.auth'], @referrer, tracking_acquisition_sources)
  end

  def tracking_acquisition_sources
    acquisition_cookie = cookies[User::UserTracking::COOKIE_LIFETIME]
    ActiveSupport::JSON.decode(acquisition_cookie) if acquisition_cookie
  end

  def login_user(session_index, url)
    reset_session
    build_user.process_user
    session[:user_id] = build_user.user.id
    increase_session_count(build_user.user)
    # To keep users logged in
    cookies.permanent[:oauth_uid] = build_user.user.uid

    index = :join_grouvly_url
    session[index] = url if url.present? && session_index == index
  end

  def set_referral_tracking_url
    @referrer = referrer
    index = :join_grouvly_url

    if session[index]
      [index, session[index]]
    else
      [nil, nil]
    end
  end

  def process_invite_wings
    url = session[:join_grouvly_url].split('/').last
    url = new_user_payment_url({ reservation: url })
    redirect_to url
  end

  def set_flash
    if @referrer.present?
      user = build_user.user
      user_decorator = UserDecorator.new(@referrer)

      if @referrer != user && @referrer != user.referrer
        flash[:warning] = if user.new? && user.referrer.present?
          I18n.t('user.sessions.join.new_applicant', name: user_decorator.name)
        elsif user.accepted?
          I18n.t('user.sessions.join.member')
        elsif user.pending? || user.rejected? || user.blocked?
          I18n.t('user.sessions.join.applicant')
        end
      end
    end
  end

  def render_page_of_logged_in_user
    build_user.user.update_from_facebook

    if session[:join_grouvly_url]
      process_invite_wings
    elsif build_user.user.wing? && @referrer.present?
      redirect_to apply_user_membership_url
    else
      set_flash
      redirect_to user_root_url
    end
  end

  def set_admin_session
    user = env['omniauth.auth']['info']
    session[:admin_id] = user['email']
    session[:admin_first_name] = user['first_name']
    session[:admin_last_name] = user['last_name']
    session[:admin_photo] = user['image']
  end

  def increase_session_count(user)
    user.session_count = (user.session_count.to_i + 1).to_s
  end
end
